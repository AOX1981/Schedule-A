module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    @current_user = authenticate_via_token || authenticate_via_session
    unless @current_user
      render json: {
        code: "unauthorized",
        message: "Authentication required. Provide a valid Bearer token or session."
      }, status: :unauthorized
    end
  end

  def authenticate_via_token
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")
    raw_token = header.split(" ", 2).last
    api_token = ApiToken.find_by_raw_token(raw_token)
    api_token&.user
  end

  def authenticate_via_session
    return nil unless session[:user_id]
    User.find_by(id: session[:user_id])
  end

  def current_user
    @current_user
  end

  def client_ip
    request.remote_ip
  end
end
