require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(email: "valid@example.com", password: "password123", full_name: "Valid User")
    assert user.valid?
  end

  test "requires email" do
    user = User.new(password: "password123", full_name: "No Email")
    assert_not user.valid?
    assert user.errors[:email].present?
  end

  test "requires unique email" do
    user = User.new(email: users(:default).email, password: "password123", full_name: "Dup")
    assert_not user.valid?
  end

  test "downcases email on save" do
    user = User.create!(email: "UPPER@EXAMPLE.COM", password: "password123", full_name: "Upper")
    assert_equal "upper@example.com", user.email
  end

  test "requires full name" do
    user = User.new(email: "test2@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:full_name].present?
  end
end
