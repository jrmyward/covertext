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
end
