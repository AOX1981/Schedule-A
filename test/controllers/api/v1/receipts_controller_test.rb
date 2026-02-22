require "test_helper"

class Api::V1::ReceiptsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @headers = auth_headers(users(:default))
    @receipt = receipts(:default)
  end

  test "index returns paginated receipts" do
    get api_v1_receipts_path, headers: @headers

    assert_response :ok
    assert json_response["receipts"].is_a?(Array)
    assert json_response["pagination"].present?
    assert json_response["pagination"]["current_page"].present?
    assert json_response["pagination"]["total_count"].present?
  end

  test "index filters by status" do
    get api_v1_receipts_path(status: "confirmed"), headers: @headers

    assert_response :ok
    json_response["receipts"].each do |r|
      assert_equal "confirmed", r["status"]
    end
  end

  test "index filters by designation" do
    get api_v1_receipts_path(designation: "business"), headers: @headers

    assert_response :ok
    json_response["receipts"].each do |r|
      assert_equal "business", r["designation"]
    end
  end

  test "show returns receipt with expense lines" do
    get api_v1_receipt_path(@receipt), headers: @headers

    assert_response :ok
    assert_equal @receipt.id, json_response["receipt"]["id"]
    assert_equal @receipt.receipt_number, json_response["receipt"]["receipt_number"]
    assert json_response["receipt"]["expense_lines"].is_a?(Array)
  end

  test "create a receipt" do
    post api_v1_receipts_path, params: {
      receipt: {
        store_name: "Best Buy",
        city: "Dallas",
        state: "TX",
        transaction_date: "2026-02-20",
        total_amount: 199.99,
        designation: "business",
        business_profile_id: business_profiles(:default).id,
        account_id: accounts(:default).id
      }
    }, headers: @headers, as: :json

    assert_response :created
    assert_equal "Best Buy", json_response["receipt"]["store_name"]
    assert json_response["receipt"]["receipt_number"].present?
  end

  test "update a receipt" do
    patch api_v1_receipt_path(@receipt), params: {
      receipt: { store_name: "Updated Store" }
    }, headers: @headers, as: :json

    assert_response :ok
    assert_equal "Updated Store", json_response["receipt"]["store_name"]
  end

  test "confirm a receipt" do
    pending = receipts(:pending_receipt)
    post confirm_api_v1_receipt_path(pending), headers: @headers

    assert_response :ok
    assert_equal "confirmed", json_response["receipt"]["status"]
  end

  test "destroy a receipt" do
    assert_difference("Receipt.count", -1) do
      delete api_v1_receipt_path(receipts(:pending_receipt)), headers: @headers
    end

    assert_response :ok
  end
end
