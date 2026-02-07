require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "successful login redirects to dashboard" do
    user = users(:john_owner)
    post login_path, params: { email: user.email, password: "password123" }

    assert_redirected_to admin_dashboard_path
    assert_equal "Logged in successfully", flash[:notice]
  end

  test "failed login shows error" do
    post login_path, params: { email: "wrong@example.com", password: "wrong" }

    assert_response :unprocessable_entity
    assert_match "Invalid email or password", response.body
  end

  test "logout redirects to login" do
    user = users(:john_owner)
    sign_in(user)

    delete logout_path
    assert_redirected_to login_path
    assert_equal "Logged out successfully", flash[:notice]
  end
end
