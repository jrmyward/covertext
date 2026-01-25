class MessageLog < ApplicationRecord
  belongs_to :agency
  belongs_to :request, optional: true

  validates :direction, presence: true
end
