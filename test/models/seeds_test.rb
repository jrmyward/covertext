require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "seeds create expected records without errors" do
    # Clear and reload seeds
    [ AuditEvent, Delivery, MessageLog, Request, Document, Policy, Client, ConversationSession, User, Agency, Account ].each(&:destroy_all)

    assert_nothing_raised do
      load Rails.root.join("db/seeds.rb")
    end

    assert_equal 1, Account.count, "Should create 1 account"
    assert_equal 1, Agency.count, "Should create 1 agency"
    assert_equal 1, User.count, "Should create 1 user"
    assert_equal 2, Client.count, "Should create 2 clients"
    assert_equal 6, Policy.count, "Should create 6 policies"
    assert_equal 6, Document.count, "Should create 6 documents"

    # Verify user belongs to account
    assert_equal Account.first, User.first.account

    # Verify documents have attached files
    assert_equal 6, Document.joins(:file_attachment).count, "All documents should have attached files"
  end
end
