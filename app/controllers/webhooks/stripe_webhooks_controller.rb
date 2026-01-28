# frozen_string_literal: true

module Webhooks
  class StripeWebhooksController < ApplicationController
    skip_before_action :require_authentication
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        render json: { error: "Invalid webhook" }, status: :bad_request
        return
      end

      # Handle the event
      case event.type
      when "customer.subscription.updated", "customer.subscription.deleted"
        handle_subscription_update(event.data.object)
      when "invoice.payment_succeeded"
        handle_payment_success(event.data.object)
      when "invoice.payment_failed"
        handle_payment_failure(event.data.object)
      end

      render json: { received: true }, status: :ok
    end

    private

    def handle_subscription_update(subscription)
      agency = Agency.find_by(stripe_subscription_id: subscription.id)
      return unless agency

      agency.update!(
        subscription_status: subscription.status,
        plan_name: subscription.metadata.plan_name || agency.plan_name
      )

      Rails.logger.info "Updated subscription for agency #{agency.id}: #{subscription.status}"
    end

    def handle_payment_success(invoice)
      return unless invoice.subscription

      agency = Agency.find_by(stripe_subscription_id: invoice.subscription)
      return unless agency

      agency.update!(subscription_status: "active")
      Rails.logger.info "Payment succeeded for agency #{agency.id}"
    end

    def handle_payment_failure(invoice)
      return unless invoice.subscription

      agency = Agency.find_by(stripe_subscription_id: invoice.subscription)
      return unless agency

      agency.update!(subscription_status: "past_due")
      Rails.logger.warn "Payment failed for agency #{agency.id}"
    end
  end
end
