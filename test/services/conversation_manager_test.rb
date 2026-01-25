require "test_helper"

class ConversationManagerTest < ActiveSupport::TestCase
  setup do
    @agency = agencies(:reliable)
    @from_phone = "+15559876543"
  end

  test "creates ConversationSession on first inbound message" do
    inbound_log = create_inbound_message(@from_phone, "Hello")

    assert_difference "ConversationSession.count", 1 do
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)
    end

    session = ConversationSession.last
    assert_equal @agency.id, session.agency_id
    assert_equal @from_phone, session.from_phone_e164
    assert_equal "awaiting_intent_selection", session.state
    assert_not_nil session.last_activity_at
    assert_not_nil session.expires_at
  end

  test "creates outbound MessageLog with menu text" do
    inbound_log = create_inbound_message(@from_phone, "Hi")

    assert_difference "MessageLog.where(direction: 'outbound').count", 1 do
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)
    end

    outbound = MessageLog.where(direction: "outbound").last
    assert_equal @agency.id, outbound.agency_id
    assert_equal @agency.sms_phone_number, outbound.from_phone
    assert_equal @from_phone, outbound.to_phone
    assert_includes outbound.body, "Welcome to CoverText"
    assert_includes outbound.body, "CARD"
    assert_includes outbound.body, "EXPIRING"
  end

  test "updates existing session on subsequent messages" do
    inbound_log1 = create_inbound_message(@from_phone, "First")
    ConversationManager.process_inbound!(message_log_id: inbound_log1.id)

    session = ConversationSession.last
    original_id = session.id
    first_activity = session.last_activity_at

    travel 5.minutes do
      inbound_log2 = create_inbound_message(@from_phone, "Second")

      assert_no_difference "ConversationSession.count" do
        ConversationManager.process_inbound!(message_log_id: inbound_log2.id)
      end

      session.reload
      assert_equal original_id, session.id
      assert session.last_activity_at > first_activity
    end
  end

  test "resets expired session context and state" do
    # Create session that expires in the past
    session = ConversationSession.create!(
      agency: @agency,
      from_phone_e164: @from_phone,
      state: "some_other_state",
      context: { "old_data" => "should_be_cleared" },
      last_activity_at: 20.minutes.ago,
      expires_at: 5.minutes.ago
    )

    inbound_log = create_inbound_message(@from_phone, "New message")
    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session.reload
    assert_equal "awaiting_intent_selection", session.state
    assert session.context.present? # Has last_menu_sent_at now
    assert_not_equal "should_be_cleared", session.context["old_data"]
  end

  test "sends short menu when menu was sent recently" do
    inbound_log1 = create_inbound_message(@from_phone, "First")
    ConversationManager.process_inbound!(message_log_id: inbound_log1.id)

    first_outbound = MessageLog.where(direction: "outbound").last
    assert_includes first_outbound.body, "Welcome to CoverText"

    # Send another message within 60 seconds
    travel 30.seconds do
      inbound_log2 = create_inbound_message(@from_phone, "Second")
      ConversationManager.process_inbound!(message_log_id: inbound_log2.id)

      second_outbound = MessageLog.where(direction: "outbound").last
      assert_equal "Reply: CARD, EXPIRING, or HELP", second_outbound.body
      assert_not_includes second_outbound.body, "Welcome"
    end
  end

  test "sends full menu when menu was sent more than 60 seconds ago" do
    inbound_log1 = create_inbound_message(@from_phone, "First")
    ConversationManager.process_inbound!(message_log_id: inbound_log1.id)

    # Send another message after 61 seconds
    travel 61.seconds do
      inbound_log2 = create_inbound_message(@from_phone, "Second")
      ConversationManager.process_inbound!(message_log_id: inbound_log2.id)

      second_outbound = MessageLog.where(direction: "outbound").last
      assert_includes second_outbound.body, "Welcome to CoverText"
    end
  end

  test "creates AuditEvent for menu sent" do
    inbound_log = create_inbound_message(@from_phone, "Test")

    # Creates 2 events: intent_routed + menu_sent
    assert_difference "AuditEvent.count", 2 do
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)
    end

    menu_audit = AuditEvent.where(event_type: "conversation.menu_sent").last
    assert_equal @agency.id, menu_audit.agency_id
    assert_equal inbound_log.id, menu_audit.metadata["message_log_id"]
    assert_equal "global.menu", menu_audit.metadata["template"]
  end

  test "AuditEvent shows short menu template when applicable" do
    inbound_log1 = create_inbound_message(@from_phone, "First")
    ConversationManager.process_inbound!(message_log_id: inbound_log1.id)

    travel 30.seconds do
      inbound_log2 = create_inbound_message(@from_phone, "Second")
      ConversationManager.process_inbound!(message_log_id: inbound_log2.id)

      audit = AuditEvent.last
      assert_equal "global.menu_short", audit.metadata["template"]
    end
  end

  test "session expires_at is 15 minutes from now" do
    freeze_time do
      inbound_log = create_inbound_message(@from_phone, "Test")
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)

      session = ConversationSession.last
      expected_expiry = Time.current + 15.minutes

      assert_in_delta expected_expiry, session.expires_at, 1.second
    end
  end

  # Phase 3: Intent routing tests

  test "routes 'insurance card' to awaiting_vehicle_selection state" do
    inbound_log = create_inbound_message(@from_phone, "I need my insurance card")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session = ConversationSession.last
    assert_equal "awaiting_vehicle_selection", session.state

    outbound = MessageLog.where(direction: "outbound").last
    assert_includes outbound.body, "Insurance card request received"
    assert_includes outbound.body, "Reply MENU"
  end

  test "routes 'policy expire' to awaiting_policy_selection state" do
    inbound_log = create_inbound_message(@from_phone, "when does my policy expire")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session = ConversationSession.last
    assert_equal "awaiting_policy_selection", session.state

    outbound = MessageLog.where(direction: "outbound").last
    assert_includes outbound.body, "Policy expiration request received"
    assert_includes outbound.body, "Reply MENU"
  end

  test "numeric shortcut '1' routes to card flow" do
    inbound_log = create_inbound_message(@from_phone, "1")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session = ConversationSession.last
    assert_equal "awaiting_vehicle_selection", session.state
  end

  test "numeric shortcut '2' routes to expiration flow" do
    inbound_log = create_inbound_message(@from_phone, "2")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session = ConversationSession.last
    assert_equal "awaiting_policy_selection", session.state
  end

  test "numeric shortcut '3' sends unsupported message then menu" do
    inbound_log = create_inbound_message(@from_phone, "3")

    # Should send 2 messages: unsupported + menu
    assert_difference "MessageLog.where(direction: 'outbound').count", 2 do
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)
    end

    messages = MessageLog.where(direction: "outbound").order(:created_at).last(2)
    assert_includes messages[0].body, "not sure how to help"
    assert_includes messages[1].body, "Welcome to CoverText"

    session = ConversationSession.last
    assert_equal "awaiting_intent_selection", session.state
  end

  test "help keyword sends unsupported message then menu" do
    inbound_log = create_inbound_message(@from_phone, "I need to talk to an agent")

    assert_difference "MessageLog.where(direction: 'outbound').count", 2 do
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)
    end

    messages = MessageLog.where(direction: "outbound").order(:created_at).last(2)
    assert_includes messages[0].body, "not sure how to help"
    assert_includes messages[1].body, "Welcome to CoverText"
  end

  test "creates intent_routed audit event" do
    inbound_log = create_inbound_message(@from_phone, "send me my card")

    # Creates 1 event: intent_routed (no menu_sent because we're in card flow now)
    assert_difference "AuditEvent.count", 1 do
      ConversationManager.process_inbound!(message_log_id: inbound_log.id)
    end

    audit = AuditEvent.where(event_type: "conversation.intent_routed").order(:created_at).last
    assert_equal "insurance_card", audit.metadata["intent"]
    assert audit.metadata["confidence"] > 0
    assert_not_nil audit.metadata["normalized_body"]
  end

  test "in awaiting_vehicle_selection, random text gets menu guidance" do
    # First get into the card flow
    session = ConversationSession.create!(
      agency: @agency,
      from_phone_e164: @from_phone,
      state: "awaiting_vehicle_selection",
      context: {},
      last_activity_at: Time.current,
      expires_at: Time.current + 15.minutes
    )

    inbound_log = create_inbound_message(@from_phone, "random text")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    outbound = MessageLog.where(direction: "outbound").last
    assert_equal "Reply MENU to return to the main menu.", outbound.body

    session.reload
    assert_equal "awaiting_vehicle_selection", session.state # Still in same state
  end

  test "in awaiting_vehicle_selection, 'menu' returns to intent selection" do
    session = ConversationSession.create!(
      agency: @agency,
      from_phone_e164: @from_phone,
      state: "awaiting_vehicle_selection",
      context: {},
      last_activity_at: Time.current,
      expires_at: Time.current + 15.minutes
    )

    inbound_log = create_inbound_message(@from_phone, "menu")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session.reload
    assert_equal "awaiting_intent_selection", session.state

    outbound = MessageLog.where(direction: "outbound").last
    assert_includes outbound.body, "Welcome to CoverText"
  end

  test "in awaiting_policy_selection, 'cancel' returns to intent selection" do
    session = ConversationSession.create!(
      agency: @agency,
      from_phone_e164: @from_phone,
      state: "awaiting_policy_selection",
      context: {},
      last_activity_at: Time.current,
      expires_at: Time.current + 15.minutes
    )

    inbound_log = create_inbound_message(@from_phone, "cancel")

    ConversationManager.process_inbound!(message_log_id: inbound_log.id)

    session.reload
    assert_equal "awaiting_intent_selection", session.state
  end

  private

  def create_inbound_message(from_phone, body)
    MessageLog.create!(
      agency: @agency,
      direction: "inbound",
      from_phone: from_phone,
      to_phone: @agency.sms_phone_number,
      body: body,
      provider_message_id: "SM#{SecureRandom.hex(16)}",
      media_count: 0
    )
  end
end
