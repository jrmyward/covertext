class CreateMessageLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :message_logs do |t|
      t.references :agency, null: false, foreign_key: true
      t.references :request, foreign_key: true
      t.string :direction, null: false
      t.string :from_phone
      t.string :to_phone
      t.text :body
      t.string :provider_message_id
      t.integer :media_count, default: 0

      t.timestamps
    end

    add_index :message_logs, :provider_message_id
  end
end
