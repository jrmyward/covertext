class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.references :request, null: false, foreign_key: true
      t.string :method, null: false
      t.string :status, null: false
      t.string :provider_message_id
      t.datetime :last_status_at

      t.timestamps
    end

    add_index :deliveries, :provider_message_id
  end
end
