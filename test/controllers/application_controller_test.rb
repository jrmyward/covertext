require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john_owner)
    @account = accounts(:reliable_group)
    @agency = agencies(:reliable)
  end

  test "current_account returns user's account when logged in" do
    sign_in(@user)
    get admin_billing_path
    assert_response :success
  end

  test "require_active_subscription allows access when subscription active and agency active" do
    @account.update!(subscription_status: "active")
    @agency.update!(active: true)
    sign_in(@user)

    get admin_requests_path
    assert_response :success
  end

  test "require_active_subscription redirects to billing when subscription inactive" do
    @account.update!(subscription_status: "canceled")
    sign_in(@user)

    get admin_requests_path
    assert_redirected_to admin_billing_path
    assert_match /subscription is inactive/, flash[:alert]
  end

  test "require_active_subscription redirects when no active agencies" do
    @account.update!(subscription_status: "active")
    @account.agencies.update_all(active: false)
    sign_in(@user)

    get admin_requests_path
    assert_redirected_to admin_billing_path
    assert_match /No active agencies/, flash[:alert]
  end
end
