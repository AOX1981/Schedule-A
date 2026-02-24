module Web
  class ReceiptsController < ApplicationController
    before_action :require_login
    before_action :set_receipt, only: [:show, :edit, :update, :destroy, :confirm]

    def index
      @receipts = current_user.receipts
        .includes(:account, :business_profile, :expense_lines)
        .order(created_at: :desc)

      @receipts = @receipts.where(status: params[:status]) if params[:status].present?
      @receipts = @receipts.where(designation: params[:designation]) if params[:designation].present?
    end

    def show
      @expense_lines = @receipt.expense_lines.order(:line_number)
      @new_expense_line = @receipt.expense_lines.build
    end

    def new
      @receipt = current_user.receipts.build(designation: "business")
    end

    def create
      @receipt = current_user.receipts.build(receipt_params)
      @receipt.image.attach(params[:receipt][:image]) if params[:receipt][:image].present?

      if @receipt.save
        AuditLog.log!(user: current_user, auditable: @receipt, action: "create", ip_address: request.remote_ip)
        if @receipt.image.attached?
          extracted = ReceiptExtractionService.new(@receipt).extract!
          @receipt.reload
          if extracted.present? && extracted.except(:line_items).values.any?(&:present?)
            flash[:notice] = "Receipt uploaded and processed! Review the extracted data below."
          else
            flash[:alert] = "Receipt uploaded but OCR could not extract data from this image. Please fill in the details manually."
          end
        else
          flash[:notice] = "Receipt created successfully."
        end
        redirect_to web_receipt_path(@receipt)
      else
        flash.now[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @receipt.assign_attributes(receipt_params)
      changed = @receipt.changes
      if @receipt.save
        AuditLog.log!(user: current_user, auditable: @receipt, action: "update",
                      changed_fields: changed, ip_address: request.remote_ip)
        flash[:notice] = "Receipt updated."
        redirect_to web_receipt_path(@receipt)
      else
        flash.now[:alert] = "Please fix the errors below."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      AuditLog.log!(user: current_user, auditable: @receipt, action: "delete", ip_address: request.remote_ip)
      @receipt.destroy!
      flash[:notice] = "Receipt deleted."
      redirect_to web_receipts_path
    end

    def confirm
      @receipt.confirm!
      AuditLog.log!(user: current_user, auditable: @receipt, action: "confirm", ip_address: request.remote_ip)
      flash[:notice] = "Receipt confirmed! Expense lines are now included in your totals."
      redirect_to web_receipt_path(@receipt)
    end

    private

    def set_receipt
      @receipt = current_user.receipts.find(params[:id])
    end

    def receipt_params
      params.require(:receipt).permit(
        :store_name, :city, :state, :transaction_date, :transaction_time,
        :total_amount, :designation, :business_profile_id, :account_id
      )
    end
  end
end
