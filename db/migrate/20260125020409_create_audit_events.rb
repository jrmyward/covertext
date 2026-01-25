class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      t.references :agency, null: false, foreign_key: true
      t.references :request, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
