require "test_helper"

class Api::V1::AccountsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @headers = auth_headers(users(:default))
    @account = accounts(:default)
  end

  test "index returns user accounts" do
    get api_v1_accounts_path, headers: @headers

    assert_response :ok
    assert json_response["accounts"].is_a?(Array)
  end

  test "show returns an account" do
    get api_v1_account_path(@account), headers: @headers

    assert_response :ok
    assert_equal @account.id, json_response["account"]["id"]
    assert_equal "4242", json_response["account"]["last4"]
  end

  test "create an account" do
    post api_v1_accounts_path, params: {
      account: {
        nickname: "Amex Gold",
        last4: "1234",
        account_type: "credit_card"
      }
    }, headers: @headers, as: :json

    assert_response :created
    assert_equal "Amex Gold", json_response["account"]["nickname"]
    assert_equal "1234", json_response["account"]["last4"]
  end

  test "create fails with invalid last4" do
    post api_v1_accounts_path, params: {
      account: {
        nickname: "Bad",
        last4: "12",
        account_type: "credit_card"
      }
    }, headers: @headers, as: :json

    assert_response :unprocessable_entity
  end

  test "update an account" do
    patch api_v1_account_path(@account), params: {
      account: { nickname: "Updated Card" }
    }, headers: @headers, as: :json

    assert_response :ok
    assert_equal "Updated Card", json_response["account"]["nickname"]
  end

  test "destroy an account" do
    assert_difference("Account.count", -1) do
      delete api_v1_account_path(@account), headers: @headers
    end

    assert_response :ok
  end
end
