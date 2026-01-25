class CreatePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :policies do |t|
      t.references :contact, null: false, foreign_key: true
      t.string :label, null: false
      t.string :policy_type, null: false
      t.date :expires_on, null: false

      t.timestamps
    end
  end
end
