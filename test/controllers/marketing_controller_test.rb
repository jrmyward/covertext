require "test_helper"

class MarketingControllerTest < ActionDispatch::IntegrationTest
  test "homepage is publicly accessible" do
    get root_path
    assert_response :success
  end

  test "homepage displays hero section" do
    get root_path
    assert_select "h2", text: /Let Clients Text for Insurance Cards/
  end

  test "homepage has signup CTA" do
    get root_path
    assert_select "a[href=?]", signup_path, text: /Start a Pilot/
  end

  test "homepage displays pricing" do
    get root_path
    assert_match /\$49/, response.body
  end
end
