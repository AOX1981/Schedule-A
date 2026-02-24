module Web
  class DashboardController < ApplicationController
    before_action :require_login

    def show
      @recent_receipts = current_user.receipts
        .includes(:account, :expense_lines)
        .order(created_at: :desc)
        .limit(5)

      confirmed = current_user.expense_lines
        .joins(:receipt)
        .where(receipts: { designation: "business", status: "confirmed" })

      @total_receipts = current_user.receipts.count
      @pending_count = current_user.receipts.where(status: "pending").count
      @total_deductions = confirmed.sum(:writeoff_value).to_f.round(2)
      @expense_count = confirmed.count
    end
  end
end
