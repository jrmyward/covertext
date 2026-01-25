class ConversationManager
  SESSION_EXPIRY = 15.minutes
  MENU_RATE_LIMIT = 60.seconds

  def self.process_inbound!(message_log_id:)
    new(message_log_id: message_log_id).process!
  end

  def initialize(message_log_id:)
    @message_log_id = message_log_id
  end

  def process!
    load_message_log
    find_or_create_session
    handle_session_expiry if session_expired?
    update_session_activity
    route_and_respond
  end

  private

  attr_reader :message_log_id, :message_log, :session

  def load_message_log
    @message_log = MessageLog.find(message_log_id)
  end

  def find_or_create_session
    @session = ConversationSession.find_or_initialize_by(
      agency_id: message_log.agency_id,
      from_phone_e164: message_log.from_phone
    )

    # Initialize state for new sessions
    if session.new_record?
      session.state = "awaiting_intent_selection"
      session.context = {}
    end
  end

  def session_expired?
    session.persisted? && session.expires_at && session.expires_at < Time.current
  end

  def handle_session_expiry
    session.context = {}
    session.state = "awaiting_intent_selection"
  end

  def update_session_activity
    session.assign_attributes(
      last_activity_at: Time.current,
      expires_at: Time.current + SESSION_EXPIRY
    )
    session.save!
  end

  def route_and_respond
    case session.state
    when "awaiting_intent_selection"
      handle_intent_selection
    when "awaiting_vehicle_selection", "awaiting_policy_selection"
      handle_in_flow_message
    else
      # Unknown state, reset to menu
      reset_to_menu
    end
  end

  def handle_intent_selection
    body = message_log.body.to_s.strip

    # Handle numeric menu shortcuts
    case body
    when "1"
      transition_to_card_flow
      return
    when "2"
      transition_to_expiration_flow
      return
    when "3"
      send_unsupported_then_menu
      return
    end

    # Route via IntentRouter
    routing = IntentRouter.route(
      body: body,
      state: session.state,
      last_menu_sent_at: session.context["last_menu_sent_at"]
    )

    create_intent_audit(routing)

    case routing[:intent]
    when :insurance_card
      transition_to_card_flow
    when :policy_expiration
      transition_to_expiration_flow
    when :help_or_other
      send_unsupported_then_menu
    when :menu
      send_menu
    else
      send_menu
    end
  end

  def handle_in_flow_message
    body = message_log.body.to_s.strip.downcase

    # Check for menu/cancel commands
    if body == "menu" || body == "cancel" || body == "restart"
      reset_to_menu
    else
      # Phase 3: no selections accepted yet
      send_simple_message(MessageTemplates::IN_FLOW_MENU_GUIDANCE)
    end
  end

  def transition_to_card_flow
    session.update!(state: "awaiting_vehicle_selection")
    send_simple_message(MessageTemplates::CARD_PLACEHOLDER_PROMPT)
  end

  def transition_to_expiration_flow
    session.update!(state: "awaiting_policy_selection")
    send_simple_message(MessageTemplates::EXPIRE_PLACEHOLDER_PROMPT)
  end

  def send_unsupported_then_menu
    send_simple_message(MessageTemplates::GLOBAL_UNSUPPORTED)
    send_menu
  end

  def reset_to_menu
    session.update!(state: "awaiting_intent_selection")
    send_menu
  end

  def send_simple_message(body)
    OutboundMessenger.send_sms!(
      agency: message_log.agency,
      to_phone: message_log.from_phone,
      body: body
    )
  end

  def send_menu
    # Only update last_menu_sent_at if we're sending the menu
    if should_send_short_menu?
      send_short_menu
    else
      send_full_menu
    end
    update_last_menu_sent_at
    create_menu_audit_event
  end

  def should_send_short_menu?
    return false unless session.context["last_menu_sent_at"]

    last_sent = Time.zone.parse(session.context["last_menu_sent_at"])
    Time.current - last_sent < MENU_RATE_LIMIT
  rescue ArgumentError
    false
  end

  def send_full_menu
    OutboundMessenger.send_sms!(
      agency: message_log.agency,
      to_phone: message_log.from_phone,
      body: MessageTemplates::GLOBAL_MENU
    )
    @menu_template_used = "global.menu"
  end

  def send_short_menu
    OutboundMessenger.send_sms!(
      agency: message_log.agency,
      to_phone: message_log.from_phone,
      body: MessageTemplates::GLOBAL_MENU_SHORT
    )
    @menu_template_used = "global.menu_short"
  end

  def update_last_menu_sent_at
    session.context["last_menu_sent_at"] = Time.current.iso8601
    session.save!
  end

  def create_menu_audit_event
    AuditEvent.create!(
      agency_id: message_log.agency_id,
      event_type: "conversation.menu_sent",
      metadata: {
        message_log_id: message_log_id,
        template: @menu_template_used,
        session_id: session.id
      }
    )
  end

  def create_intent_audit(routing)
    AuditEvent.create!(
      agency_id: message_log.agency_id,
      event_type: "conversation.intent_routed",
      metadata: {
        message_log_id: message_log_id,
        intent: routing[:intent].to_s,
        confidence: routing[:confidence],
        reason: routing[:reason],
        normalized_body: message_log.body.to_s.strip.downcase.gsub(/\s+/, " "),
        session_id: session.id
      }
    )
  end
end
