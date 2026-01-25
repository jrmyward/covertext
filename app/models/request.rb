class Request < ApplicationRecord
  belongs_to :agency
  belongs_to :contact, optional: true
  has_many :message_logs
  has_many :deliveries, dependent: :destroy
  has_many :audit_events

  validates :request_type, presence: true
  validates :status, presence: true
end
