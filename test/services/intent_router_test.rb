require "test_helper"

class IntentRouterTest < ActiveSupport::TestCase
  test "command word 'card' routes to insurance_card with confidence 1.0" do
    result = IntentRouter.route(body: "card", state: "awaiting_intent_selection")

    assert_equal :insurance_card, result[:intent]
    assert_equal 1.0, result[:confidence]
    assert_includes result[:reason], "command_word"
  end

  test "command word 'expiring' routes to policy_expiration with confidence 1.0" do
    result = IntentRouter.route(body: "expiring", state: "awaiting_intent_selection")

    assert_equal :policy_expiration, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "command word 'menu' routes to menu with confidence 1.0" do
    result = IntentRouter.route(body: "menu", state: "awaiting_intent_selection")

    assert_equal :menu, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "command word 'cancel' routes to menu" do
    result = IntentRouter.route(body: "cancel", state: "awaiting_intent_selection")

    assert_equal :menu, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "command word 'help' routes to help_or_other" do
    result = IntentRouter.route(body: "help", state: "awaiting_intent_selection")

    assert_equal :help_or_other, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "strong pattern 'insurance card' routes to insurance_card" do
    result = IntentRouter.route(
      body: "please send my insurance card",
      state: "awaiting_intent_selection"
    )

    assert_equal :insurance_card, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "strong pattern 'id card' routes to insurance_card" do
    result = IntentRouter.route(body: "need my id card", state: "awaiting_intent_selection")

    assert_equal :insurance_card, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "strong pattern 'proof of insurance' routes to insurance_card" do
    result = IntentRouter.route(
      body: "I need proof of insurance",
      state: "awaiting_intent_selection"
    )

    assert_equal :insurance_card, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "weak pattern 'card insurance' routes to insurance_card" do
    result = IntentRouter.route(body: "card for my auto insurance", state: "awaiting_intent_selection")

    assert_equal :insurance_card, result[:intent]
    assert_equal 0.85, result[:confidence]
  end

  test "strong pattern 'policy expire' routes to policy_expiration" do
    result = IntentRouter.route(
      body: "when does my policy expire",
      state: "awaiting_intent_selection"
    )

    assert_equal :policy_expiration, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "strong pattern 'renewal date' routes to policy_expiration" do
    result = IntentRouter.route(body: "what is my renewal date", state: "awaiting_intent_selection")

    assert_equal :policy_expiration, result[:intent]
    assert_equal 1.0, result[:confidence]
  end

  test "weak pattern 'renewal' routes to policy_expiration" do
    result = IntentRouter.route(body: "need info on renewal", state: "awaiting_intent_selection")

    assert_equal :policy_expiration, result[:intent]
    assert_equal 0.85, result[:confidence]
  end

  test "help keyword 'agent' routes to help_or_other" do
    result = IntentRouter.route(body: "talk to an agent", state: "awaiting_intent_selection")

    assert_equal :help_or_other, result[:intent]
    assert_equal 0.9, result[:confidence]
  end

  test "help keyword 'human' routes to help_or_other" do
    result = IntentRouter.route(body: "I need a human", state: "awaiting_intent_selection")

    assert_equal :help_or_other, result[:intent]
    assert_equal 0.9, result[:confidence]
  end

  test "help keyword 'claim' routes to help_or_other" do
    result = IntentRouter.route(body: "file a claim", state: "awaiting_intent_selection")

    assert_equal :help_or_other, result[:intent]
    assert_equal 0.9, result[:confidence]
  end

  test "ambiguous input 'hey' routes to menu" do
    result = IntentRouter.route(body: "hey", state: "awaiting_intent_selection")

    assert_equal :menu, result[:intent]
    assert_equal 0.0, result[:confidence]
    assert_includes result[:reason], "no_match"
  end

  test "nonsensical input 'pet dinosaur' routes to menu" do
    result = IntentRouter.route(body: "pet dinosaur", state: "awaiting_intent_selection")

    assert_equal :menu, result[:intent]
    assert_equal 0.0, result[:confidence]
  end

  test "normalizes whitespace and case" do
    result1 = IntentRouter.route(body: "  CARD  ", state: "awaiting_intent_selection")
    result2 = IntentRouter.route(body: "card", state: "awaiting_intent_selection")

    assert_equal result2[:intent], result1[:intent]
    assert_equal result2[:confidence], result1[:confidence]
  end

  test "handles empty body" do
    result = IntentRouter.route(body: "", state: "awaiting_intent_selection")

    assert_equal :menu, result[:intent]
  end

  test "handles nil body" do
    result = IntentRouter.route(body: nil, state: "awaiting_intent_selection")

    assert_equal :menu, result[:intent]
  end
end
