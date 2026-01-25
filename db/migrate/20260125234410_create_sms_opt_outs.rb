class CreateSmsOptOuts < ActiveRecord::Migration[8.1]
  def change
    create_table :sms_opt_outs do |t|
      t.references :agency, null: false, foreign_key: true
      t.string :phone_e164, null: false
      t.datetime :opted_out_at, null: false
      t.datetime :last_block_notice_at

      t.timestamps
    end

    add_index :sms_opt_outs, [ :agency_id, :phone_e164 ], unique: true
  end
end
