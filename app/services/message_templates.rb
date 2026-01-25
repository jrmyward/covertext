module MessageTemplates
  GLOBAL_MENU = <<~TEXT.strip
    Welcome to CoverText! 📋

    Reply with:
    • CARD - Get your insurance card
    • EXPIRING - Check policy expiration dates
    • HELP - Show this menu again

    What can I help you with today?
  TEXT

  GLOBAL_MENU_SHORT = <<~TEXT.strip
    Reply: CARD, EXPIRING, or HELP
  TEXT

  CARD_PLACEHOLDER_PROMPT = <<~TEXT.strip
    Insurance card request received. Reply MENU to return to the main menu. (Vehicle selection coming next.)
  TEXT

  EXPIRE_PLACEHOLDER_PROMPT = <<~TEXT.strip
    Policy expiration request received. Reply MENU to return to the main menu. (Policy selection coming next.)
  TEXT

  GLOBAL_UNSUPPORTED = <<~TEXT.strip
    I'm not sure how to help with that request. For assistance with other matters, please contact your agency directly.

    Reply MENU to see available options.
  TEXT

  IN_FLOW_MENU_GUIDANCE = <<~TEXT.strip
    Reply MENU to return to the main menu.
  TEXT
end
