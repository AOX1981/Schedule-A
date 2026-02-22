require "test_helper"

class Api::V1::SummariesControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @headers = auth_headers(users(:default))
  end

  test "by_category returns category breakdown" do
    get api_v1_summaries_by_category_path, headers: @headers

    assert_response :ok
    assert json_response["summary"].is_a?(Array)
    json_response["summary"].each do |entry|
      assert entry["tax_category"].present?
      assert entry["line_count"].is_a?(Integer)
      assert entry["total_cost"].is_a?(Numeric)
      assert entry["total_writeoff"].is_a?(Numeric)
    end
  end

  test "by_vendor returns vendor breakdown" do
    get api_v1_summaries_by_vendor_path, headers: @headers

    assert_response :ok
    assert json_response["summary"].is_a?(Array)
  end

  test "by_account returns account breakdown" do
    get api_v1_summaries_by_account_path, headers: @headers

    assert_response :ok
    assert json_response["summary"].is_a?(Array)
  end

  test "by_month returns monthly breakdown" do
    get api_v1_summaries_by_month_path, headers: @headers

    assert_response :ok
    assert json_response["summary"].is_a?(Array)
  end

  test "schedule_c returns schedule c totals" do
    get api_v1_summaries_schedule_c_path, headers: @headers

    assert_response :ok
    assert json_response["schedule_c"].present?
    assert json_response["schedule_c"]["line_items"].is_a?(Array)
    assert json_response["schedule_c"]["grand_total"].is_a?(Numeric)
  end

  test "schedule_c filters by tax year" do
    get api_v1_summaries_schedule_c_path(tax_year: 2026), headers: @headers

    assert_response :ok
    assert json_response["schedule_c"].present?
  end
end
