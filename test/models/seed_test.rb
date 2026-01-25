require "test_helper"

class SeedTest < ActiveSupport::TestCase
  test "seeds run without errors and create expected data" do
    # Clear existing data
    [ AuditEvent, Delivery, MessageLog, Request, Document, Policy, Contact, ConversationSession, User, Agency ].each(&:destroy_all)

    # Run seeds
    assert_nothing_raised do
      load Rails.root.join("db/seeds.rb")
    end

    # Verify expected counts
    assert_equal 1, Agency.count, "Should create 1 agency"
    assert_equal 1, User.count, "Should create 1 user"
    assert_equal 2, Contact.count, "Should create 2 contacts"
    assert_equal 6, Policy.count, "Should create 6 policies"
    assert_equal 6, Document.count, "Should create 6 documents"

    # Verify all documents have attached files
    assert_equal 6, Document.joins(:file_attachment).count, "All documents should have files attached"

    # Verify agency has valid phone number
    agency = Agency.first
    assert agency.sms_phone_number.present?
    assert agency.sms_phone_number.start_with?("+1")
  end
end
