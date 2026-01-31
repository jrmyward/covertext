class Account < ApplicationRecord
  has_many :agencies, dependent: :destroy
  # has_many :users - will be added in US-003 after account_id column exists on users

  validates :name, presence: true
  validates :stripe_customer_id, uniqueness: true, allow_nil: true
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true
  validates :subscription_status, inclusion: { in: %w[active canceled incomplete incomplete_expired past_due trialing unpaid paused] }, allow_nil: true

  def subscription_active?
    subscription_status == "active"
  end
end
