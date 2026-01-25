require "test_helper"

class SmsOptOutTest < ActiveSupport::TestCase
  setup do
    @agency = agencies(:reliable)
  end

  test "valid opt-out" do
    opt_out = SmsOptOut.new(
      agency: @agency,
      phone_e164: "+15551234567"
    )
    assert opt_out.valid?
  end

  test "requires phone_e164" do
    opt_out = SmsOptOut.new(agency: @agency)
    assert_not opt_out.valid?
    assert_includes opt_out.errors[:phone_e164], "can't be blank"
  end

  test "phone_e164 must be in E.164 format" do
    opt_out = SmsOptOut.new(
      agency: @agency,
      phone_e164: "5551234567" # Missing +
    )
    assert_not opt_out.valid?
    assert_includes opt_out.errors[:phone_e164], "is invalid"
  end

  test "phone_e164 must be unique per agency" do
    SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567"
    )

    duplicate = SmsOptOut.new(
      agency: @agency,
      phone_e164: "+15551234567"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:phone_e164], "has already been taken"
  end

  test "phone_e164 can be same across different agencies" do
    other_agency = agencies(:acme)

    SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567"
    )

    opt_out = SmsOptOut.new(
      agency: other_agency,
      phone_e164: "+15551234567"
    )
    assert opt_out.valid?
  end

  test "opted_out_at is set automatically on create" do
    opt_out = SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567"
    )
    assert opt_out.opted_out_at.present?
    assert_in_delta Time.current, opt_out.opted_out_at, 2.seconds
  end

  test "should_send_block_notice? returns true when never sent" do
    opt_out = SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567"
    )
    assert opt_out.should_send_block_notice?
  end

  test "should_send_block_notice? returns false when sent recently" do
    opt_out = SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567",
      last_block_notice_at: 1.hour.ago
    )
    assert_not opt_out.should_send_block_notice?
  end

  test "should_send_block_notice? returns true when sent over 24 hours ago" do
    opt_out = SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567",
      last_block_notice_at: 25.hours.ago
    )
    assert opt_out.should_send_block_notice?
  end

  test "mark_block_notice_sent! updates last_block_notice_at" do
    opt_out = SmsOptOut.create!(
      agency: @agency,
      phone_e164: "+15551234567"
    )

    assert_nil opt_out.last_block_notice_at

    opt_out.mark_block_notice_sent!
    opt_out.reload

    assert opt_out.last_block_notice_at.present?
    assert_in_delta Time.current, opt_out.last_block_notice_at, 2.seconds
  end
end
