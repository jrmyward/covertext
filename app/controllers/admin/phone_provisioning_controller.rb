module Admin
  class PhoneProvisioningController < BaseController
    skip_before_action :require_active_subscription
    before_action :require_owner

    def create
      unless current_account.subscription_active?
        redirect_to admin_dashboard_path, alert: "An active subscription is required to provision a phone number"
        return
      end

      result = Telnyx::PhoneProvisioningService.new(current_agency).call

      if result.success?
        redirect_to admin_dashboard_path, notice: "Phone number provisioned successfully!"
      else
        redirect_to admin_dashboard_path, alert: result.message
      end
    end

    private

    def require_owner
      unless current_user.role == "owner"
        redirect_to admin_dashboard_path, alert: "Only account owners can provision phone numbers"
      end
    end
  end
end
