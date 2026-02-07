module Admin
  class DashboardController < BaseController
    skip_before_action :require_active_subscription

    def show
      @account = current_account
      @agency = current_agency
    end
  end
end
