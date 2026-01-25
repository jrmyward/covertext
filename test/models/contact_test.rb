require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "requires mobile_phone_e164" do
    contact = Contact.new(agency: agencies(:reliable), first_name: "Test", last_name: "User")
    assert_not contact.valid?
    assert_includes contact.errors[:mobile_phone_e164], "can't be blank"
  end

  test "requires unique mobile_phone_e164 scoped to agency" do
    duplicate = Contact.new(agency: agencies(:reliable), mobile_phone_e164: contacts(:alice).mobile_phone_e164)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:mobile_phone_e164], "has already been taken"
  end

  test "allows same mobile_phone_e164 for different agencies" do
    contact = Contact.new(agency: agencies(:acme), mobile_phone_e164: contacts(:alice).mobile_phone_e164)
    assert contact.valid?
  end

  test "creates contact with valid attributes" do
    contact = Contact.new(agency: agencies(:reliable), first_name: "New", last_name: "Contact", mobile_phone_e164: "+15559999999")
    assert contact.valid?
    assert contact.save
  end
end
