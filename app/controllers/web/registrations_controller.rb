module Web
  class RegistrationsController < ApplicationController
    layout "application"

    def new
      redirect_to web_dashboard_path if logged_in?
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        session[:user_id] = @user.id
        flash[:notice] = "Account created! Welcome to Schedule A."
        redirect_to web_dashboard_path
      else
        flash.now[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :full_name)
    end
  end
end
