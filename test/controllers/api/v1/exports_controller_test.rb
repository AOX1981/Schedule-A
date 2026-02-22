require "test_helper"

class Api::V1::ExportsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @headers = auth_headers(users(:default))
  end

  test "schedule_c_csv returns CSV file" do
    get api_v1_exports_schedule_c_csv_path(tax_year: 2026), headers: @headers

    assert_response :ok
    assert_equal "text/csv", response.content_type.split(";").first
  end

  test "schedule_c_pdf returns PDF file" do
    get api_v1_exports_schedule_c_pdf_path(tax_year: 2026), headers: @headers

    assert_response :ok
    assert_equal "application/pdf", response.content_type.split(";").first
  end

  test "expense_lines_csv returns CSV file" do
    get api_v1_exports_expense_lines_csv_path(tax_year: 2026), headers: @headers

    assert_response :ok
    assert_equal "text/csv", response.content_type.split(";").first
  end

  test "exports require authentication" do
    get api_v1_exports_schedule_c_csv_path

    assert_response :unauthorized
  end
end
