require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "requires name" do
    account = Account.new
    assert_not account.valid?
    assert_includes account.errors[:name], "can't be blank"
  end

  test "creates account with valid attributes" do
    account = Account.new(name: "Test Account")
    assert account.valid?
    assert account.save
  end

  test "requires unique stripe_customer_id" do
    Account.create!(name: "First Account", stripe_customer_id: "cus_123")
    duplicate = Account.new(name: "Second Account", stripe_customer_id: "cus_123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:stripe_customer_id], "has already been taken"
  end

  test "allows nil stripe_customer_id" do
    account = Account.new(name: "Account Without Stripe", stripe_customer_id: nil)
    assert account.valid?
  end

  test "requires unique stripe_subscription_id" do
    Account.create!(name: "First Account", stripe_subscription_id: "sub_123")
    duplicate = Account.new(name: "Second Account", stripe_subscription_id: "sub_123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:stripe_subscription_id], "has already been taken"
  end

  test "allows nil stripe_subscription_id" do
    account = Account.new(name: "Account Without Stripe", stripe_subscription_id: nil)
    assert account.valid?
  end

  test "validates subscription_status inclusion" do
    account = Account.new(name: "Test Account", subscription_status: "invalid_status")
    assert_not account.valid?
    assert_includes account.errors[:subscription_status], "is not included in the list"
  end

  test "allows valid subscription_status values" do
    %w[active canceled incomplete incomplete_expired past_due trialing unpaid paused].each do |status|
      account = Account.new(name: "Test Account", subscription_status: status)
      assert account.valid?, "Expected subscription_status '#{status}' to be valid"
    end
  end

  test "allows nil subscription_status" do
    account = Account.new(name: "Test Account", subscription_status: nil)
    assert account.valid?
  end

  test "has_many agencies" do
    assert Account.reflect_on_association(:agencies).macro == :has_many
  end

  # Test for has_many :users will be added in US-003 when account_id is added to users table
end
