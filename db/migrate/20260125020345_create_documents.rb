class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :policy, null: false, foreign_key: true
      t.string :kind, null: false, default: "auto_id_card"

      t.timestamps
    end
  end
end
