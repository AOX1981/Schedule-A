module Api
  module V1
    class ReceiptsController < BaseController
      before_action :set_receipt, only: [:show, :update, :destroy, :confirm]

      def index
        scope = current_user.receipts.includes(:account, :business_profile, expense_lines: :receipt)

        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(designation: params[:designation]) if params[:designation].present?

        if params[:start_date].present? && params[:end_date].present?
          scope = scope.where(transaction_date: params[:start_date]..params[:end_date])
        end

        scope = scope.order(created_at: :desc)
        pagy, receipts = pagy(scope, limit: params[:per_page] || 25, page: params[:page] || 1)

        render json: {
          receipts: ReceiptSerializer.new(receipts).to_h,
          pagination: pagy_metadata(pagy)
        }
      end

      def show
        render json: { receipt: ReceiptSerializer.new(@receipt).to_h }
      end

      def create
        receipt = current_user.receipts.build(receipt_params)

        if params[:image].present?
          receipt.image.attach(params[:image])
        end

        receipt.save!
        AuditLog.log!(user: current_user, auditable: receipt, action: "create", ip_address: client_ip)

        if receipt.image.attached?
          ReceiptExtractionJob.perform_later(receipt.id)
        end

        render json: { receipt: ReceiptSerializer.new(receipt).to_h }, status: :created
      end

      def update
        old_attrs = @receipt.attributes.slice(*receipt_params.keys.map(&:to_s))
        @receipt.update!(receipt_params)
        changed = old_attrs.select { |k, v| v != @receipt.attributes[k] }
        AuditLog.log!(user: current_user, auditable: @receipt, action: "update",
                      changed_fields: changed, ip_address: client_ip)
        render json: { receipt: ReceiptSerializer.new(@receipt).to_h }
      end

      def destroy
        AuditLog.log!(user: current_user, auditable: @receipt, action: "delete", ip_address: client_ip)
        @receipt.destroy!
        render json: { message: "Receipt deleted" }
      end

      def confirm
        @receipt.confirm!
        AuditLog.log!(user: current_user, auditable: @receipt, action: "confirm", ip_address: client_ip)
        render json: { receipt: ReceiptSerializer.new(@receipt).to_h }
      end

      private

      def set_receipt
        @receipt = current_user.receipts.includes(:expense_lines, :account).find(params[:id])
      end

      def receipt_params
        params.require(:receipt).permit(
          :store_name, :city, :state, :transaction_date, :transaction_time,
          :total_amount, :designation, :business_profile_id, :account_id
        )
      end
    end
  end
end
