module Web
  class SessionsController < ApplicationController
    layout "application"

    def new
      redirect_to web_dashboard_path if logged_in?
    end

    def create
      user = User.find_by(email: params[:email]&.downcase)
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        flash[:notice] = "Welcome back, #{user.full_name}!"
        redirect_to web_dashboard_path
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:user_id)
      flash[:notice] = "You have been logged out."
      redirect_to login_path
    end
  end
end
