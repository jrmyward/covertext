class IntentRouter
  CONFIDENCE_THRESHOLD = 0.8

  # Command words that map directly to intents with 100% confidence
  COMMANDS = {
    "menu" => :menu,
    "cancel" => :menu,
    "restart" => :menu,
    "help" => :help_or_other,
    "card" => :insurance_card,
    "expiring" => :policy_expiration
  }.freeze

  # Keyword patterns for scoring intents
  STRONG_PATTERNS = {
    insurance_card: [
      /insurance\s+card/i,
      /id\s+card/i,
      /proof\s+of\s+insurance/i
    ],
    policy_expiration: [
      /policy\s+expir/i,
      /policy\s+expiration/i,
      /renewal\s+date/i
    ]
  }.freeze

  WEAK_PATTERNS = {
    insurance_card: [
      /\b(my|the|our)\s+(insurance\s+)?card\b/i,
      /\bcard\b.{0,30}(insurance|auto|vehicle|car|truck)/i,
      /(insurance|auto|vehicle|car|truck).{0,30}\bcard\b/i
    ],
    policy_expiration: [
      /\b(expire|expiration|renew|renewal)\b/i
    ]
  }.freeze

  HELP_KEYWORDS = %w[
    agent human representative change add remove
    address vehicle driver billing claim
  ].freeze

  def self.route(body:, state:, last_menu_sent_at: nil)
    new(body: body, state: state, last_menu_sent_at: last_menu_sent_at).route
  end

  def initialize(body:, state:, last_menu_sent_at: nil)
    @raw_body = body
    @normalized_body = normalize(body)
    @state = state
    @last_menu_sent_at = last_menu_sent_at
  end

  def route
    # Check for direct command words first
    if COMMANDS.key?(@normalized_body)
      intent = COMMANDS[@normalized_body]
      return {
        intent: intent,
        confidence: 1.0,
        reason: "command_word: #{@normalized_body}"
      }
    end

    # Score all intents
    scores = {
      insurance_card: score_insurance_card,
      policy_expiration: score_policy_expiration,
      help_or_other: score_help_or_other
    }

    # Find best match
    best_intent, best_score = scores.max_by { |_intent, score| score }

    if best_score >= CONFIDENCE_THRESHOLD
      {
        intent: best_intent,
        confidence: best_score,
        reason: "keyword_match: #{best_score}"
      }
    else
      {
        intent: :menu,
        confidence: 0.0,
        reason: "no_match: showing_menu"
      }
    end
  end

  private

  def normalize(body)
    body.to_s.strip.downcase.gsub(/\s+/, " ")
  end

  def score_insurance_card
    score = 0.0

    # Strong patterns = 1.0
    STRONG_PATTERNS[:insurance_card].each do |pattern|
      return 1.0 if @normalized_body.match?(pattern)
    end

    # Weak patterns = 0.85
    WEAK_PATTERNS[:insurance_card].each do |pattern|
      score = 0.85 if @normalized_body.match?(pattern)
    end

    score
  end

  def score_policy_expiration
    score = 0.0

    # Strong patterns = 1.0
    STRONG_PATTERNS[:policy_expiration].each do |pattern|
      return 1.0 if @normalized_body.match?(pattern)
    end

    # Weak patterns = 0.85
    WEAK_PATTERNS[:policy_expiration].each do |pattern|
      score = 0.85 if @normalized_body.match?(pattern)
    end

    score
  end

  def score_help_or_other
    # Check if any help keywords are present
    HELP_KEYWORDS.each do |keyword|
      return 0.9 if @normalized_body.include?(keyword)
    end

    0.0
  end
end
