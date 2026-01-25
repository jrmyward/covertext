class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :agency, null: false, foreign_key: true
      t.references :contact, foreign_key: true
      t.string :request_type, null: false
      t.string :status, null: false
      t.string :selected_ref
      t.string :failure_reason
      t.text :inbound_body
      t.datetime :fulfilled_at

      t.timestamps
    end
  end
end
