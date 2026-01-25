class Agency < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :conversation_sessions, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :message_logs, dependent: :destroy
  has_many :audit_events, dependent: :destroy
  has_many :sms_opt_outs, dependent: :destroy

  validates :name, presence: true
  validates :sms_phone_number, presence: true, uniqueness: true
end
