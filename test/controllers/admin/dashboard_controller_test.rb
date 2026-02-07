require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:john_owner)
      sign_in(@user)
    end

    test "should get dashboard" do
      get admin_dashboard_url
      assert_response :success
    end

    test "should skip subscription check" do
      # Make account inactive
      @user.account.update!(subscription_status: "canceled")

      get admin_dashboard_url
      assert_response :success
    end

    test "should require authentication" do
      sign_out
      get admin_dashboard_url
      assert_redirected_to login_path
    end
  end
end
