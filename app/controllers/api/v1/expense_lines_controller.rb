module Api
  module V1
    class ExpenseLinesController < BaseController
      before_action :set_receipt
      before_action :set_expense_line, only: [:show, :update, :destroy]

      def index
        lines = @receipt.expense_lines.order(:line_number)
        render json: { expense_lines: ExpenseLineSerializer.new(lines).to_h }
      end

      def show
        render json: { expense_line: ExpenseLineSerializer.new(@expense_line).to_h }
      end

      def create
        line = @receipt.expense_lines.build(expense_line_params)
        line.user = current_user
        line.save!
        AuditLog.log!(user: current_user, auditable: line, action: "create", ip_address: client_ip)
        render json: { expense_line: ExpenseLineSerializer.new(line).to_h }, status: :created
      end

      def update
        old_attrs = @expense_line.attributes.slice(*expense_line_params.keys.map(&:to_s))
        @expense_line.update!(expense_line_params)
        changed = old_attrs.select { |k, v| v != @expense_line.attributes[k] }
        AuditLog.log!(user: current_user, auditable: @expense_line, action: "update",
                      changed_fields: changed, ip_address: client_ip)
        render json: { expense_line: ExpenseLineSerializer.new(@expense_line).to_h }
      end

      def destroy
        AuditLog.log!(user: current_user, auditable: @expense_line, action: "delete", ip_address: client_ip)
        @expense_line.destroy!
        render json: { message: "Expense line deleted" }
      end

      private

      def set_receipt
        @receipt = current_user.receipts.find(params[:receipt_id])
      end

      def set_expense_line
        @expense_line = @receipt.expense_lines.find(params[:id])
      end

      def expense_line_params
        params.require(:expense_line).permit(:item, :cost, :tax_category, :writeoff_percent)
      end
    end
  end
end
