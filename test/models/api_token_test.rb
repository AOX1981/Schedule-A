require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "generate_for creates token and returns raw token" do
    token, raw = ApiToken.generate_for(users(:default))
    assert token.persisted?
    assert raw.present?
    assert token.expires_at > Time.current
  end

  test "find_by_raw_token finds active token" do
    _token, raw = ApiToken.generate_for(users(:default))
    found = ApiToken.find_by_raw_token(raw)
    assert found.present?
    assert_equal users(:default).id, found.user_id
  end

  test "find_by_raw_token returns nil for revoked token" do
    token, raw = ApiToken.generate_for(users(:default))
    token.revoke!
    assert_nil ApiToken.find_by_raw_token(raw)
  end

  test "find_by_raw_token returns nil for blank" do
    assert_nil ApiToken.find_by_raw_token("")
    assert_nil ApiToken.find_by_raw_token(nil)
  end

  test "revoke marks token" do
    token, _raw = ApiToken.generate_for(users(:default))
    token.revoke!
    assert token.revoked?
  end
end
