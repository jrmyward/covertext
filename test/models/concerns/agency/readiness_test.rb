require "test_helper"

class Agency::ReadinessTest < ActiveSupport::TestCase
  test "subscription_ready? returns true when account has active subscription" do
    agency = agencies(:reliable)
    agency.account.update!(subscription_status: "active")

    assert agency.subscription_ready?
  end

  test "subscription_ready? returns false when account has inactive subscription" do
    agency = agencies(:reliable)
    agency.account.update!(subscription_status: "canceled")

    assert_not agency.subscription_ready?
  end

  test "phone_ready? returns true when phone_sms is present" do
    agency = agencies(:reliable)
    agency.update!(phone_sms: "+15551234567")

    assert agency.phone_ready?
  end

  test "phone_ready? returns false when phone_sms is nil" do
    agency = agencies(:reliable)
    agency.update!(phone_sms: nil)

    assert_not agency.phone_ready?
  end

  test "fully_ready? returns true when both subscription and phone are ready" do
    agency = agencies(:reliable)
    agency.account.update!(subscription_status: "active")
    agency.update!(phone_sms: "+15551234567")

    assert agency.fully_ready?
  end

  test "fully_ready? returns false when subscription is not ready" do
    agency = agencies(:reliable)
    agency.account.update!(subscription_status: "canceled")
    agency.update!(phone_sms: "+15551234567")

    assert_not agency.fully_ready?
  end

  test "fully_ready? returns false when phone is not ready" do
    agency = agencies(:reliable)
    agency.account.update!(subscription_status: "active")
    agency.update!(phone_sms: nil)

    assert_not agency.fully_ready?
  end

  test "fully_ready? returns false when neither is ready" do
    agency = agencies(:reliable)
    agency.account.update!(subscription_status: "canceled")
    agency.update!(phone_sms: nil)

    assert_not agency.fully_ready?
  end
end
