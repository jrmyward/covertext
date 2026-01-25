require "test_helper"

class ConversationSessionTest < ActiveSupport::TestCase
  test "requires from_phone_e164" do
    session = ConversationSession.new(agency: agencies(:reliable), state: "active")
    assert_not session.valid?
    assert_includes session.errors[:from_phone_e164], "can't be blank"
  end

  test "requires state" do
    session = ConversationSession.new(agency: agencies(:reliable), from_phone_e164: "+15559999999")
    assert_not session.valid?
    assert_includes session.errors[:state], "can't be blank"
  end

  test "requires unique from_phone_e164 scoped to agency" do
    duplicate = ConversationSession.new(agency: agencies(:reliable), from_phone_e164: conversation_sessions(:active_session).from_phone_e164, state: "active")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:from_phone_e164], "has already been taken"
  end

  test "allows same from_phone_e164 for different agencies" do
    session = ConversationSession.new(agency: agencies(:acme), from_phone_e164: conversation_sessions(:active_session).from_phone_e164, state: "active")
    assert session.valid?
  end

  test "context defaults to empty hash" do
    session = ConversationSession.create!(agency: agencies(:reliable), from_phone_e164: "+15558888888", state: "active")
    assert_equal({}, session.context)
  end
end
