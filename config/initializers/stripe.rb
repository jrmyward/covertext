# frozen_string_literal: true

Rails.application.configure do
  # Configure Stripe API key from credentials
  Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
end
