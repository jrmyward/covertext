require "test_helper"

class AgencyTest < ActiveSupport::TestCase
  test "requires name" do
    agency = Agency.new(sms_phone_number: "+15559999999")
    assert_not agency.valid?
    assert_includes agency.errors[:name], "can't be blank"
  end

  test "requires sms_phone_number" do
    agency = Agency.new(name: "Test Agency")
    assert_not agency.valid?
    assert_includes agency.errors[:sms_phone_number], "can't be blank"
  end

  test "requires unique sms_phone_number" do
    duplicate = Agency.new(name: "Duplicate Agency", sms_phone_number: agencies(:reliable).sms_phone_number)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:sms_phone_number], "has already been taken"
  end

  test "creates agency with valid attributes" do
    agency = Agency.new(name: "Valid Agency", sms_phone_number: "+15559999999")
    assert agency.valid?
    assert agency.save
  end

  test "settings defaults to empty hash" do
    agency = Agency.create!(name: "Test Agency", sms_phone_number: "+15558888888")
    assert_equal({}, agency.settings)
  end

  test "live_enabled defaults to false" do
    agency = Agency.create!(name: "Test Agency", sms_phone_number: "+15557777777")
    assert_equal false, agency.live_enabled
  end

  test "requires unique stripe_customer_id" do
    agencies(:reliable).update!(stripe_customer_id: "cus_123")
    duplicate = Agency.new(name: "New Agency", sms_phone_number: "+15556666666", stripe_customer_id: "cus_123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:stripe_customer_id], "has already been taken"
  end

  test "requires unique stripe_subscription_id" do
    agencies(:reliable).update!(stripe_subscription_id: "sub_123")
    duplicate = Agency.new(name: "New Agency", sms_phone_number: "+15555555555", stripe_subscription_id: "sub_123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:stripe_subscription_id], "has already been taken"
  end

  test "subscription_active? returns true when status is active" do
    agency = agencies(:reliable)
    agency.update!(subscription_status: "active")
    assert agency.subscription_active?
  end

  test "subscription_active? returns false when status is not active" do
    agency = agencies(:reliable)
    agency.update!(subscription_status: "past_due")
    assert_not agency.subscription_active?
  end

  test "can_go_live? requires both active subscription and live_enabled" do
    agency = agencies(:reliable)

    # Neither active nor enabled
    agency.update!(subscription_status: nil, live_enabled: false)
    assert_not agency.can_go_live?

    # Active but not enabled
    agency.update!(subscription_status: "active", live_enabled: false)
    assert_not agency.can_go_live?

    # Enabled but not active
    agency.update!(subscription_status: "past_due", live_enabled: true)
    assert_not agency.can_go_live?

    # Both active and enabled
    agency.update!(subscription_status: "active", live_enabled: true)
    assert agency.can_go_live?
  end
end
