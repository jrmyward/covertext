class Contact < ApplicationRecord
  belongs_to :agency
  has_many :policies, dependent: :destroy
  has_many :requests

  validates :mobile_phone_e164, presence: true, uniqueness: { scope: :agency_id }
end
