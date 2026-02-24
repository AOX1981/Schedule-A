module Web
  class AccountsController < ApplicationController
    before_action :require_login
    before_action :set_account, only: [:edit, :update, :destroy]

    def new
      @account = current_user.accounts.build
    end

    def create
      @account = current_user.accounts.build(account_params)
      if @account.save
        flash[:notice] = "Account added."
        redirect_to web_settings_path
      else
        flash.now[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @account.update(account_params)
        flash[:notice] = "Account updated."
        redirect_to web_settings_path
      else
        flash.now[:alert] = "Please fix the errors below."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @account.destroy!
      flash[:notice] = "Account removed."
      redirect_to web_settings_path
    end

    private

    def set_account
      @account = current_user.accounts.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:nickname, :last4, :account_type)
    end
  end
end
