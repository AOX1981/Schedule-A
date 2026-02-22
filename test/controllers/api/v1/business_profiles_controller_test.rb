require "test_helper"

class Api::V1::BusinessProfilesControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @headers = auth_headers(users(:default))
    @profile = business_profiles(:default)
  end

  test "index returns user profiles" do
    get api_v1_business_profiles_path, headers: @headers

    assert_response :ok
    assert json_response["business_profiles"].is_a?(Array)
    assert json_response["business_profiles"].length >= 1
  end

  test "index requires authentication" do
    get api_v1_business_profiles_path

    assert_response :unauthorized
    assert_equal "unauthorized", json_response["code"]
  end

  test "show returns a profile" do
    get api_v1_business_profile_path(@profile), headers: @headers

    assert_response :ok
    assert_equal @profile.id, json_response["business_profile"]["id"]
    assert_equal @profile.business_name, json_response["business_profile"]["business_name"]
    assert_equal @profile.tax_year, json_response["business_profile"]["tax_year"]
  end

  test "show returns 404 for other user profile" do
    get api_v1_business_profile_path(@profile), headers: auth_headers(users(:other))

    assert_response :not_found
  end

  test "create a new profile" do
    post api_v1_business_profiles_path, params: {
      business_profile: {
        business_name: "New Biz",
        business_type: "single_member_llc",
        tax_year: 2025
      }
    }, headers: @headers, as: :json

    assert_response :created
    assert_equal "New Biz", json_response["business_profile"]["business_name"]
    assert_equal 2025, json_response["business_profile"]["tax_year"]
  end

  test "create fails with duplicate tax year" do
    post api_v1_business_profiles_path, params: {
      business_profile: {
        business_name: "Duplicate",
        tax_year: @profile.tax_year
      }
    }, headers: @headers, as: :json

    assert_response :unprocessable_entity
  end

  test "update a profile" do
    patch api_v1_business_profile_path(@profile), params: {
      business_profile: { business_name: "Updated Name" }
    }, headers: @headers, as: :json

    assert_response :ok
    assert_equal "Updated Name", json_response["business_profile"]["business_name"]
  end

  test "destroy a profile" do
    assert_difference("BusinessProfile.count", -1) do
      delete api_v1_business_profile_path(@profile), headers: @headers
    end

    assert_response :ok
  end
end
