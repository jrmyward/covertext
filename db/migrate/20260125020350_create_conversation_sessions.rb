class CreateConversationSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_sessions do |t|
      t.references :agency, null: false, foreign_key: true
      t.string :from_phone_e164, null: false
      t.string :state, null: false
      t.jsonb :context, default: {}
      t.datetime :last_activity_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :conversation_sessions, [ :agency_id, :from_phone_e164 ], unique: true
  end
end
