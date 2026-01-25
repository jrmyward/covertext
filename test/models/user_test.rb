require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires first_name" do
    user = User.new(agency: agencies(:reliable), last_name: "Doe", email: "test@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "requires last_name" do
    user = User.new(agency: agencies(:reliable), first_name: "John", email: "test@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "requires email" do
    user = User.new(agency: agencies(:reliable), first_name: "John", last_name: "Doe", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires unique email" do
    duplicate = User.new(agency: agencies(:acme), first_name: "Jane", last_name: "Doe", email: users(:john_admin).email, password: "password")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "creates user with valid attributes" do
    user = User.new(agency: agencies(:reliable), first_name: "John", last_name: "Doe", email: "newuser@example.com", password: "password")
    assert user.valid?
    assert user.save
  end

  test "role defaults to admin" do
    user = User.create!(agency: agencies(:reliable), first_name: "Test", last_name: "User", email: "roletest@example.com", password: "password")
    assert_equal "admin", user.role
  end

  test "has_secure_password is enabled" do
    user = users(:john_admin)
    assert user.authenticate("password123")
    assert_not user.authenticate("wrongpassword")
  end
end
