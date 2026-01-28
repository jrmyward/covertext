ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

# Ensure Twilio is stubbed in tests
ENV["TWILIO_ACCOUNT_SID"] ||= "test_account_sid"
ENV["TWILIO_AUTH_TOKEN"] ||= "test_auth_token"

# Set test Stripe API key
Stripe.api_key = "sk_test_123456789"

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Reset Twilio client before each test to ensure clean stubbed state
    setup do
      TwilioClient.reset!
      # Stub Stripe API calls by default
      stub_stripe_api_calls
    end

    # Add more helper methods to be used by all tests here...
    def sign_in(user)
      post login_path, params: { email: user.email, password: "password123" }
    end

    def sign_out
      delete logout_path
    end

    private

    def stub_stripe_api_calls
      # Stub common Stripe API endpoints to prevent real API calls
      stub_request(:any, /api.stripe.com/).to_return(
        status: 200,
        body: { id: "stub_response" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end
  end
end
