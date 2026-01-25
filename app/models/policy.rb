class Policy < ApplicationRecord
  belongs_to :contact
  has_many :documents, dependent: :destroy

  validates :label, presence: true
  validates :policy_type, presence: true
  validates :expires_on, presence: true
end
