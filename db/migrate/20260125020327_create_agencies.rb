class CreateAgencies < ActiveRecord::Migration[8.1]
  def change
    create_table :agencies do |t|
      t.string :name, null: false
      t.string :sms_phone_number, null: false
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :agencies, :sms_phone_number, unique: true
  end
end
