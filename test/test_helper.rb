ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

module ApiTestHelper
  def auth_headers(user = nil)
    user ||= users(:default)
    _token_record, raw_token = ApiToken.generate_for(user)
    { "Authorization" => "Bearer #{raw_token}", "Content-Type" => "application/json" }
  end

  def json_response
    JSON.parse(response.body)
  end
end
