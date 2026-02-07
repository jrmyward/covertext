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
    assert_select "a[href=?]", signup_path, text: /Get Started/
  end

  test "homepage displays pricing" do
    get root_path
    assert_match /Simple, Transparent Pricing/, response.body
    assert_match /\$49/, response.body # Starter tier
    assert_match /\$99/, response.body # Professional tier
  end

  test "should get privacy policy without authentication" do
    get privacy_path
    assert_response :success
    assert_select "h1", text: "Privacy Policy"
    assert_select "a[href=?]", terms_path
    assert_select "a[href=?]", sms_consent_path
  end

  test "should get terms of service without authentication" do
    get terms_path
    assert_response :success
    assert_select "h1", text: "Terms of Service"
    assert_select "a[href=?]", privacy_path
    assert_select "a[href=?]", sms_consent_path
  end

  test "terms page should contain required sections" do
    get terms_path
    assert_response :success

    # Check for key terms sections
    assert_select "h2", text: /Acceptance of Terms/
    assert_select "h2", text: /Definitions/
    assert_select "h2", text: /Subscription and Billing/
    assert_select "h2", text: /SMS Service Usage Rules/
    assert_select "h2", text: /Prohibited Uses/
    assert_select "h2", text: /Limitation of Liability/
    assert_select "h2", text: /Termination/
    assert_select "h2", text: /Governing Law/

    # Check for compliance statements
    assert_match "customer-initiated, transactional SMS", @response.body
    assert_match "non-refundable", @response.body
    assert_match "Workhorse Solutions, LLC", @response.body
    assert_match "support@covertext.app", @response.body
  end

  test "terms page should have table of contents with anchor links" do
    get terms_path
    assert_response :success
    assert_select "a[href='#acceptance']"
    assert_select "a[href='#subscription']"
    assert_select "a[href='#sms-usage']"
    assert_select "a[href='#governing-law']"
  end

  test "should get SMS consent policy without authentication" do
    get sms_consent_path
    assert_response :success
    assert_select "h1", text: /SMS Consent/
    assert_select "a[href=?]", privacy_path
    assert_select "a[href=?]", terms_path
  end

  test "sms consent page should contain required sections" do
    get sms_consent_path
    assert_response :success

    # Check for key SMS consent sections
    assert_select "h2", text: /About This SMS Program/
    assert_select "h2", text: /How to Opt In/
    assert_select "h2", text: /Message Types and Frequency/
    assert_select "h2", text: /Getting Help/
    assert_select "h2", text: /How to Opt Out/
    assert_select "h2", text: /Sample Messages/

    # Check for compliance statements
    assert_match "customer-initiated, transactional", @response.body
    assert_match "Message and data rates may apply", @response.body
    assert_match /reply STOP/i, @response.body
    assert_match /reply HELP/i, @response.body
    assert_match "We do not sell or share your phone number", @response.body
    assert_match "support@covertext.app", @response.body
  end

  test "sms consent page should include exact keyword responses" do
    get sms_consent_path
    assert_response :success

    # Check for HELP response
    assert_match /Text your insurance agency for ID cards & policy info/, @response.body

    # Check for STOP confirmation
    assert_match /You've been unsubscribed from CoverText messages/, @response.body
  end

  test "privacy page should contain required sections" do
    get privacy_path
    assert_response :success

    # Check for key privacy policy sections
    assert_select "h2", text: /Information We Collect/
    assert_select "h2", text: /How We Use Your Information/
    assert_select "h2", text: /SMS Communications and Consent/
    assert_select "h2", text: /How We Share Your Information/
    assert_select "h2", text: /Data Security/
    assert_select "h2", text: /Contact Us/

    # Check for compliance statements
    assert_match "We do not sell personal information", @response.body
    assert_match "We do not use client phone numbers or personal information for marketing", @response.body
    assert_match "support@covertext.app", @response.body
  end

  test "privacy page should have effective date" do
    get privacy_path
    assert_response :success
    assert_match /Effective Date:.*\d{4}/, @response.body
  end

  test "privacy page should link back to home" do
    get privacy_path
    assert_response :success
    assert_select "a[href=?]", root_path, text: /Back to Home/
  end
end
