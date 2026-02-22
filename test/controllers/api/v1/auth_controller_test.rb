require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  test "register creates user and returns token" do
    post api_v1_auth_register_path, params: {
      user: {
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123",
        full_name: "New User"
      }
    }, as: :json

    assert_response :created
    assert json_response["user"]["id"].present?
    assert_equal "new@example.com", json_response["user"]["email"]
    assert_equal "New User", json_response["user"]["full_name"]
    assert json_response["token"].present?
    assert json_response["expires_at"].present?
  end

  test "register fails with invalid data" do
    post api_v1_auth_register_path, params: {
      user: { email: "", password: "short", full_name: "" }
    }, as: :json

    assert_response :unprocessable_entity
    assert_equal "validation_error", json_response["code"]
    assert json_response["details"].is_a?(Array)
  end

  test "register fails with duplicate email" do
    post api_v1_auth_register_path, params: {
      user: {
        email: users(:default).email,
        password: "password123",
        password_confirmation: "password123",
        full_name: "Duplicate"
      }
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "login returns token with valid credentials" do
    post api_v1_auth_login_path, params: {
      email: users(:default).email,
      password: "password123"
    }, as: :json

    assert_response :ok
    assert json_response["token"].present?
    assert json_response["user"]["id"].present?
    assert json_response["expires_at"].present?
  end

  test "login fails with wrong password" do
    post api_v1_auth_login_path, params: {
      email: users(:default).email,
      password: "wrongpassword"
    }, as: :json

    assert_response :unauthorized
    assert_equal "unauthorized", json_response["code"]
  end

  test "login fails with nonexistent email" do
    post api_v1_auth_login_path, params: {
      email: "nonexistent@example.com",
      password: "password123"
    }, as: :json

    assert_response :unauthorized
  end

  test "logout revokes token" do
    headers = auth_headers(users(:default))
    delete api_v1_auth_logout_path, headers: headers

    assert_response :ok
    assert_equal "Logged out successfully", json_response["message"]
  end
end
