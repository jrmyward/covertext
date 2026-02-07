require "test_helper"

class SeedTest < ActiveSupport::TestCase
  test "seeds run without errors and create expected data" do
    # Clear existing data
    [ AuditEvent, Delivery, MessageLog, Request, Document, Policy, Client, ConversationSession, User, Agency, Account ].each(&:destroy_all)

    # Run seeds
    assert_nothing_raised do
      load Rails.root.join("db/seeds.rb")
    end

    # Verify expected counts - multitenancy model: 1 Account with 3 Agencies
    assert_equal 1, Account.count, "Should create 1 account"
    assert_equal 3, Agency.count, "Should create 3 agencies"
    assert_equal 1, User.count, "Should create 1 user"
    assert_equal 4, Client.count, "Should create 4 clients (2 per agency)"
    assert_equal 10, Policy.count, "Should create 10 policies"
    assert_equal 10, Document.count, "Should create 10 documents"

    # Verify all documents have attached files
    assert_equal 10, Document.joins(:file_attachment).count, "All documents should have files attached"

    # Verify agencies belong to account
    account = Account.first
    assert_equal 3, account.agencies.count, "Account should have 3 agencies"

    # Verify 2 agencies are ready (have phone numbers) and 1 is not ready
    ready_agencies = account.agencies.select { |a| a.phone_sms.present? }
    not_ready_agencies = account.agencies.select { |a| a.phone_sms.nil? }

    assert_equal 2, ready_agencies.count, "Should have 2 ready agencies with phone numbers"
    assert_equal 1, not_ready_agencies.count, "Should have 1 not-ready agency without phone number"

    # Verify ready agencies have valid phone numbers
    ready_agencies.each do |agency|
      assert agency.phone_sms.start_with?("+1")
      assert agency.active?, "Ready agency should be active"
    end

    # Verify not-ready agency
    not_ready = not_ready_agencies.first
    assert not_ready.active?, "Not-ready agency should still be active"
    assert_not not_ready.live_enabled, "Not-ready agency should not be live_enabled"

    # Verify user belongs to account with owner role
    user = User.first
    assert_equal account, user.account
    assert_equal "owner", user.role
  end
end
