module Api
  module V1
    class AccountsController < BaseController
      before_action :set_account, only: [:show, :update, :destroy]

      def index
        accounts = current_user.accounts.order(:nickname)
        render json: { accounts: AccountSerializer.new(accounts).to_h }
      end

      def show
        render json: { account: AccountSerializer.new(@account).to_h }
      end

      def create
        account = current_user.accounts.build(account_params)
        account.save!
        render json: { account: AccountSerializer.new(account).to_h }, status: :created
      end

      def update
        @account.update!(account_params)
        render json: { account: AccountSerializer.new(@account).to_h }
      end

      def destroy
        @account.destroy!
        render json: { message: "Account deleted" }
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
end
