class AddStripeFieldsToAgencies < ActiveRecord::Migration[8.1]
  def change
    add_column :agencies, :stripe_customer_id, :string
    add_column :agencies, :stripe_subscription_id, :string
    add_column :agencies, :subscription_status, :string
    add_column :agencies, :plan_name, :string
    add_column :agencies, :live_enabled, :boolean, default: false, null: false

    add_index :agencies, :stripe_customer_id, unique: true
    add_index :agencies, :stripe_subscription_id, unique: true
  end
end
