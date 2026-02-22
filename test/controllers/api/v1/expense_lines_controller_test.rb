require "test_helper"

class Api::V1::ExpenseLinesControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @headers = auth_headers(users(:default))
    @receipt = receipts(:default)
    @line = expense_lines(:default)
  end

  test "index returns expense lines for receipt" do
    get api_v1_receipt_expense_lines_path(@receipt), headers: @headers

    assert_response :ok
    assert json_response["expense_lines"].is_a?(Array)
    assert json_response["expense_lines"].length >= 1
  end

  test "show returns an expense line" do
    get api_v1_receipt_expense_line_path(@receipt, @line), headers: @headers

    assert_response :ok
    assert_equal @line.id, json_response["expense_line"]["id"]
    assert_equal "1001.1", json_response["expense_line"]["transaction_display_id"]
    assert_equal "Printer Paper", json_response["expense_line"]["item"]
    assert_equal "office_expense", json_response["expense_line"]["tax_category"]
  end

  test "create an expense line" do
    post api_v1_receipt_expense_lines_path(@receipt), params: {
      expense_line: {
        item: "USB Cable",
        cost: 15.99,
        tax_category: "supplies",
        writeoff_percent: 50.0
      }
    }, headers: @headers, as: :json

    assert_response :created
    assert_equal "USB Cable", json_response["expense_line"]["item"]
    assert_equal 15.99, json_response["expense_line"]["cost"].to_f
    assert_equal 50.0, json_response["expense_line"]["writeoff_percent"].to_f
    assert_equal 8.0, json_response["expense_line"]["writeoff_value"].to_f
    assert json_response["expense_line"]["transaction_display_id"].present?
  end

  test "update an expense line" do
    patch api_v1_receipt_expense_line_path(@receipt, @line), params: {
      expense_line: { writeoff_percent: 75.0 }
    }, headers: @headers, as: :json

    assert_response :ok
    assert_equal 75.0, json_response["expense_line"]["writeoff_percent"].to_f
  end

  test "create fails with invalid tax category" do
    post api_v1_receipt_expense_lines_path(@receipt), params: {
      expense_line: {
        item: "Bad Item",
        cost: 10.0,
        tax_category: "invalid_category"
      }
    }, headers: @headers, as: :json

    assert_response :unprocessable_entity
  end

  test "destroy an expense line" do
    assert_difference("ExpenseLine.count", -1) do
      delete api_v1_receipt_expense_line_path(@receipt, @line), headers: @headers
    end

    assert_response :ok
  end
end
