class AuditEvent < ApplicationRecord
  belongs_to :agency
  belongs_to :request, optional: true

  validates :event_type, presence: true
end
