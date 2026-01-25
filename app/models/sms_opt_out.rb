class SmsOptOut < ApplicationRecord
  belongs_to :agency

  validates :phone_e164, presence: true, format: { with: /\A\+\d{10,15}\z/ }
  validates :opted_out_at, presence: true
  validates :phone_e164, uniqueness: { scope: :agency_id }

  before_validation :set_opted_out_at, on: :create

  # Check if we should send a block notice (once per day max)
  def should_send_block_notice?
    last_block_notice_at.nil? || last_block_notice_at < 1.day.ago
  end

  # Mark that we sent a block notice
  def mark_block_notice_sent!
    update!(last_block_notice_at: Time.current)
  end

  private

  def set_opted_out_at
    self.opted_out_at ||= Time.current
  end
end
