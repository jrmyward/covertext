module Telnyx
  class PhoneProvisioningService
    class Result
      attr_reader :success, :message, :phone_number

      def initialize(success:, message:, phone_number: nil)
        @success = success
        @message = message
        @phone_number = phone_number
      end

      def success?
        @success
      end
    end

    def initialize(agency)
      @agency = agency
    end

    def call
      # Idempotency check
      if @agency.phone_sms.present?
        return Result.new(
          success: true,
          message: "Phone number already provisioned",
          phone_number: @agency.phone_sms
        )
      end

      # Ensure credentials are present
      ensure_credentials!

      # Purchase and configure number
      provision_number
    rescue => e
      Rails.logger.error "[Telnyx::PhoneProvisioningService] Error: #{e.message}"
      Result.new(
        success: false,
        message: "Provisioning failed: #{e.message}"
      )
    end

    private

    def provision_number
      phone_number = nil

      ActiveRecord::Base.transaction do
        # Search for available toll-free numbers
        available_numbers = search_toll_free_numbers

        if available_numbers.empty?
          return Result.new(
            success: false,
            message: "No toll-free numbers available in your area"
          )
        end

        # Purchase the first available number
        phone_number = purchase_number(available_numbers.first["phone_number"])

        # Add number to messaging profile
        add_to_messaging_profile(phone_number)

        # Update agency
        @agency.update!(
          phone_sms: phone_number,
          live_enabled: true
        )
      end

      Result.new(
        success: true,
        message: "Phone number provisioned successfully",
        phone_number: phone_number
      )
    rescue => e
      Rails.logger.error "[Telnyx::PhoneProvisioningService] Provisioning failed: #{e.message}"
      Rails.logger.error "[Telnyx::PhoneProvisioningService] Purchased number (if any): #{phone_number}"

      Result.new(
        success: false,
        message: "Phone number purchased but configuration failed. Please contact support with error code: #{e.message}"
      )
    end

    def search_toll_free_numbers
      # Search for available toll-free numbers in US
      # Using Telnyx API: GET /v2/available_phone_numbers
      # For now, this is a stub that will be implemented with actual Telnyx API calls
      # Reference: https://developers.telnyx.com/docs/api/v2/numbers/Number-Search

      api_key = Rails.application.credentials.dig(:telnyx, :api_key) || ENV["TELNYX_API_KEY"]

      # Stub for testing - in production this would call Telnyx API
      # Telnyx::AvailablePhoneNumber.list(
      #   filter: {
      #     phone_number_type: "toll_free",
      #     country_code: "US",
      #     limit: 1
      #   }
      # )

      # Return stub data for testing
      []
    end

    def purchase_number(phone_number)
      # Purchase the number via Telnyx API
      # POST /v2/number_orders
      # Stub for testing
      phone_number
    end

    def add_to_messaging_profile(phone_number)
      # Add purchased number to messaging profile
      # PATCH /v2/messaging_profiles/:id/phone_numbers
      messaging_profile_id = Rails.application.credentials.dig(:telnyx, :messaging_profile_id) ||
                             ENV["TELNYX_MESSAGING_PROFILE_ID"]

      unless messaging_profile_id
        raise "Telnyx messaging profile ID not configured"
      end

      # Stub for testing - in production this would call Telnyx API
      true
    end

    def ensure_credentials!
      api_key = Rails.application.credentials.dig(:telnyx, :api_key) || ENV["TELNYX_API_KEY"]
      messaging_profile_id = Rails.application.credentials.dig(:telnyx, :messaging_profile_id) ||
                             ENV["TELNYX_MESSAGING_PROFILE_ID"]

      unless api_key
        raise "Telnyx API key not configured. Please set it in Rails credentials or ENV."
      end

      unless messaging_profile_id
        raise "Telnyx messaging profile ID not configured. Please set it in Rails credentials or ENV."
      end
    end
  end
end
