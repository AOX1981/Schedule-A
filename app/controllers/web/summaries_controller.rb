module Web
  class SummariesController < ApplicationController
    before_action :require_login

    def index
      @tax_year = (params[:tax_year] || Date.current.year).to_i
      scope = confirmed_lines

      @by_category = scope.group(:tax_category)
        .select("tax_category, COUNT(*) as line_count, SUM(cost) as total_cost, SUM(writeoff_value) as total_writeoff")
        .reject { |s| s.tax_category.nil? }

      @by_vendor = scope.joins(:receipt)
        .group("receipts.store_name")
        .select("receipts.store_name, COUNT(*) as line_count, SUM(expense_lines.cost) as total_cost, SUM(expense_lines.writeoff_value) as total_writeoff")

      @by_month = scope.joins(:receipt)
        .where.not(receipts: { transaction_date: nil })
        .group("DATE_TRUNC('month', receipts.transaction_date)")
        .select("DATE_TRUNC('month', receipts.transaction_date) as month, COUNT(*) as line_count, SUM(expense_lines.cost) as total_cost, SUM(expense_lines.writeoff_value) as total_writeoff")
        .order("month")

      @schedule_c = build_schedule_c(scope)
    end

    private

    def confirmed_lines
      scope = current_user.expense_lines
        .joins(:receipt)
        .where(receipts: { designation: "business", status: "confirmed" })

      if @tax_year.present?
        scope = scope.where(receipts: { transaction_date: Date.new(@tax_year, 1, 1)..Date.new(@tax_year, 12, 31) })
      end

      scope
    end

    def build_schedule_c(scope)
      grouped = scope.where.not(tax_category: nil).group(:tax_category).sum(:writeoff_value)
      items = ExpenseLine::SCHEDULE_C_CATEGORIES.filter_map do |category, line_num|
        amount = (grouped[category] || 0).to_f.round(2)
        next if amount.zero?
        { line_number: line_num, category: category, total: amount }
      end.sort_by { |i| i[:line_number] }

      { items: items, grand_total: items.sum { |i| i[:total] }.round(2) }
    end
  end
end
