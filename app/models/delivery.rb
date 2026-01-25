class Delivery < ApplicationRecord
  belongs_to :request

  validates :method, presence: true
  validates :status, presence: true
end
