module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def register
        user = User.new(register_params)
        if user.save
          api_token, raw_token = ApiToken.generate_for(user)
          render json: {
            user: UserSerializer.new(user).to_h,
            token: raw_token,
            expires_at: api_token.expires_at.iso8601
          }, status: :created
        else
          render json: {
            code: "validation_error",
            message: "Registration failed",
            details: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email]&.downcase)
        if user&.authenticate(params[:password])
          api_token, raw_token = ApiToken.generate_for(user)
          render json: {
            user: UserSerializer.new(user).to_h,
            token: raw_token,
            expires_at: api_token.expires_at.iso8601
          }, status: :ok
        else
          render json: {
            code: "unauthorized",
            message: "Invalid email or password"
          }, status: :unauthorized
        end
      end

      def logout
        header = request.headers["Authorization"]
        if header&.start_with?("Bearer ")
          raw_token = header.split(" ", 2).last
          api_token = ApiToken.find_by_raw_token(raw_token)
          api_token&.revoke!
        end
        render json: { message: "Logged out successfully" }, status: :ok
      end

      private

      def register_params
        params.require(:user).permit(:email, :password, :password_confirmation, :full_name)
      end
    end
  end
end
