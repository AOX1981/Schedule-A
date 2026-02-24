module Web
  class ExpenseLinesController < ApplicationController
    before_action :require_login
    before_action :set_receipt
    before_action :set_expense_line, only: [:edit, :update, :destroy]

    def create
      @expense_line = @receipt.expense_lines.build(expense_line_params)
      @expense_line.user = current_user

      if @expense_line.save
        AuditLog.log!(user: current_user, auditable: @expense_line, action: "create", ip_address: request.remote_ip)
        flash[:notice] = "Expense line added."
      else
        flash[:alert] = @expense_line.errors.full_messages.join(", ")
      end
      redirect_to web_receipt_path(@receipt)
    end

    def edit
    end

    def update
      @expense_line.assign_attributes(expense_line_params)
      changed = @expense_line.changes
      if @expense_line.save
        AuditLog.log!(user: current_user, auditable: @expense_line, action: "update",
                      changed_fields: changed, ip_address: request.remote_ip)
        flash[:notice] = "Expense line updated."
        redirect_to web_receipt_path(@receipt)
      else
        flash.now[:alert] = "Please fix the errors below."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      AuditLog.log!(user: current_user, auditable: @expense_line, action: "delete", ip_address: request.remote_ip)
      @expense_line.destroy!
      flash[:notice] = "Expense line removed."
      redirect_to web_receipt_path(@receipt)
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
