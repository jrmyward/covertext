class ConversationSession < ApplicationRecord
  belongs_to :agency

  validates :from_phone_e164, presence: true, uniqueness: { scope: :agency_id }
  validates :state, presence: true
end
