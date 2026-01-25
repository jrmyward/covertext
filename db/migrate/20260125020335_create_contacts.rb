class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :agency, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :mobile_phone_e164, null: false

      t.timestamps
    end

    add_index :contacts, [ :agency_id, :mobile_phone_e164 ], unique: true
  end
end
