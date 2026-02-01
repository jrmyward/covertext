# frozen_string_literal: true

module Admin
  class BillingController < ApplicationController
    def show
      @account = current_user.account
      @agency = @account.agencies.where(active: true).first

      if @account&.stripe_customer_id
        # Create Stripe billing portal session
        @portal_session = Stripe::BillingPortal::Session.create(
          customer: @account.stripe_customer_id,
          return_url: admin_billing_url
        )
      end
    rescue Stripe::StripeError => e
      flash.now[:alert] = "Unable to load billing information: #{e.message}"
    end
  end
end
