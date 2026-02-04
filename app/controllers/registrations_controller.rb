# frozen_string_literal: true

class RegistrationsController < ApplicationController
  skip_before_action :require_authentication

  def new
    @registration = Forms::Registration.new
    @selected_plan = selected_plan_from_params
    @selected_interval = selected_interval_from_params
    @plan_info = Plan.info(@selected_plan, @selected_interval)
  end

  def create
    # Get selected plan and interval, validate and default
    plan = params[:plan]&.to_sym
    plan = Plan.default unless Plan.valid?(plan)

    interval = params[:interval]&.to_sym
    interval = :monthly unless [ :monthly, :yearly ].include?(interval)

    @registration = Forms::Registration.new(
      account_name: params[:registration]&.dig(:account_name),
      plan_tier: plan.to_s,
      agency_name: params[:registration]&.dig(:agency_name),

      user_first_name: params[:registration]&.dig(:user_first_name),
      user_last_name: params[:registration]&.dig(:user_last_name),
      user_email: params[:registration]&.dig(:user_email),
      user_password: params[:registration]&.dig(:user_password)
    )

    if @registration.save
      # Create Stripe checkout session
      session = Stripe::Checkout::Session.create(
        customer_email: @registration.user.email,
        mode: "subscription",
        line_items: [ {
          price: stripe_price_id_for_plan(plan, interval),
          quantity: 1
        } ],
        success_url: signup_success_url(session_id: "{CHECKOUT_SESSION_ID}", plan: plan, interval: interval),
        cancel_url: signup_url(plan: plan, interval: interval),
        metadata: {
          account_id: @registration.account.id,
          agency_id: @registration.agency.id,
          user_id: @registration.user.id,
          plan_tier: plan,
          billing_interval: interval
        },
        subscription_data: {
          metadata: {
            account_id: @registration.account.id,
            plan_tier: plan,
            billing_interval: interval
          }
        }
      )

      redirect_to session.url, allow_other_host: true
    else
      @selected_plan = selected_plan_from_params
      @selected_interval = selected_interval_from_params
      @plan_info = Plan.info(@selected_plan, @selected_interval)
      render :new, status: :unprocessable_entity
    end
  rescue Stripe::StripeError => e
    @selected_plan = selected_plan_from_params
    @selected_interval = selected_interval_from_params
    @plan_info = Plan.info(@selected_plan, @selected_interval)
    flash[:alert] = "Payment setup failed: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def success
    session_id = params[:session_id]

    begin
      checkout_session = Stripe::Checkout::Session.retrieve(session_id)

      # Get account from metadata (fallback to agency for legacy signups)
      if checkout_session.metadata.account_id
        account = Account.find(checkout_session.metadata.account_id)
      else
        agency = Agency.find(checkout_session.metadata.agency_id)
        account = agency.account
      end

      # Update account with Stripe details
      plan_tier = checkout_session.metadata.plan_tier&.to_sym
      plan_tier = Plan.default unless Plan.valid?(plan_tier)

      account.update!(
        stripe_customer_id: checkout_session.customer,
        stripe_subscription_id: checkout_session.subscription,
        subscription_status: "active",
        plan_tier: plan_tier
      )

      # Log the user in
      user = account.users.first
      session[:user_id] = user.id

      redirect_to admin_requests_path, notice: "Welcome to CoverText! Your subscription is active."
    rescue => e
      redirect_to login_path, alert: "Something went wrong. Please contact support."
    end
  end

  private

  def agency_params
    params.require(:agency).permit(:name, :phone_sms)
  end

  def selected_plan_from_params
    plan = params[:plan]&.to_sym
    Plan.valid?(plan) ? plan : Plan.default
  end

  def selected_interval_from_params
    interval = params[:interval]&.to_sym
    [ :monthly, :yearly ].include?(interval) ? interval : :yearly
  end

  def stripe_price_id_for_plan(plan, interval = :yearly)
    # Build credential key: starter_monthly_price_id, professional_yearly_price_id, etc.
    key = "#{plan}_#{interval}_price_id".to_sym

    Rails.application.credentials.dig(:stripe, key) || "price_#{plan}_#{interval}_placeholder"
  end
end
