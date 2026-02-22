require "test_helper"

class Api::V1::WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  test "inbound_email creates receipt for known user" do
    assert_difference("Receipt.count", 1) do
      post api_v1_webhooks_inbound_email_path, params: {
        from: "Test User <test@example.com>",
        subject: "Receipt from Lunch",
        text: "Attached is my receipt"
      }, as: :json
    end

    assert_response :created
    assert json_response["receipt_id"].present?
  end

  test "inbound_email handles unknown sender" do
    assert_no_difference("Receipt.count") do
      post api_v1_webhooks_inbound_email_path, params: {
        from: "unknown@nowhere.com",
        subject: "Receipt",
        text: "Body"
      }, as: :json
    end

    assert_response :ok
    assert_equal "not_found", json_response["code"]
  end
end
