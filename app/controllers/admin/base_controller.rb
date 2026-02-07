module Admin
  class BaseController < ApplicationController
    layout "admin"
    before_action :require_authentication
    before_action :require_active_subscription

    private

    def current_agency
      @current_agency ||= current_user.account.agencies.where(active: true).first
    end
    helper_method :current_agency

    def require_phone_provisioned
      return if current_agency&.phone_ready?

      redirect_to admin_dashboard_path, alert: "Please provision a phone number before accessing Requests"
    end
  end
end
