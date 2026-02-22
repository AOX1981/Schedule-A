module Api
  module V1
    class SummariesController < BaseController
      def by_category
        lines = current_user_expense_lines
        summary = lines.group(:tax_category).select(
          "tax_category",
          "COUNT(*) as line_count",
          "SUM(cost) as total_cost",
          "SUM(writeoff_value) as total_writeoff"
        )

        render json: {
          summary: summary.map { |s|
            {
              tax_category: s.tax_category,
              schedule_c_line: ExpenseLine::SCHEDULE_C_CATEGORIES[s.tax_category],
              line_count: s.line_count,
              total_cost: s.total_cost.to_f.round(2),
              total_writeoff: s.total_writeoff.to_f.round(2)
            }
          }
        }
      end

      def by_vendor
        lines = current_user_expense_lines.joins(:receipt)
        summary = lines.group("receipts.store_name").select(
          "receipts.store_name",
          "COUNT(*) as line_count",
          "SUM(expense_lines.cost) as total_cost",
          "SUM(expense_lines.writeoff_value) as total_writeoff"
        )

        render json: {
          summary: summary.map { |s|
            {
              store_name: s.store_name,
              line_count: s.line_count,
              total_cost: s.total_cost.to_f.round(2),
              total_writeoff: s.total_writeoff.to_f.round(2)
            }
          }
        }
      end

      def by_account
        lines = current_user_expense_lines.joins(receipt: :account)
        summary = lines.group("accounts.last4", "accounts.nickname").select(
          "accounts.last4",
          "accounts.nickname",
          "COUNT(*) as line_count",
          "SUM(expense_lines.cost) as total_cost",
          "SUM(expense_lines.writeoff_value) as total_writeoff"
        )

        render json: {
          summary: summary.map { |s|
            {
              account_last4: s.last4,
              account_nickname: s.nickname,
              line_count: s.line_count,
              total_cost: s.total_cost.to_f.round(2),
              total_writeoff: s.total_writeoff.to_f.round(2)
            }
          }
        }
      end

      def by_month
        lines = current_user_expense_lines.joins(:receipt)
        summary = lines
          .where.not(receipts: { transaction_date: nil })
          .group("DATE_TRUNC('month', receipts.transaction_date)")
          .select(
            "DATE_TRUNC('month', receipts.transaction_date) as month",
            "COUNT(*) as line_count",
            "SUM(expense_lines.cost) as total_cost",
            "SUM(expense_lines.writeoff_value) as total_writeoff"
          )
          .order("month")

        render json: {
          summary: summary.map { |s|
            {
              month: s.month.strftime("%Y-%m"),
              line_count: s.line_count,
              total_cost: s.total_cost.to_f.round(2),
              total_writeoff: s.total_writeoff.to_f.round(2)
            }
          }
        }
      end

      def schedule_c
        lines = current_user_expense_lines.where.not(tax_category: nil)
        grouped = lines.group(:tax_category).sum(:writeoff_value)

        schedule_c_lines = ExpenseLine::SCHEDULE_C_CATEGORIES.map { |category, line_num|
          {
            line_number: line_num,
            category: category,
            total_writeoff: (grouped[category] || 0).to_f.round(2)
          }
        }.select { |entry| entry[:total_writeoff] > 0 }
          .sort_by { |entry| entry[:line_number] }

        grand_total = schedule_c_lines.sum { |l| l[:total_writeoff] }

        render json: {
          schedule_c: {
            line_items: schedule_c_lines,
            grand_total: grand_total.round(2)
          }
        }
      end

      private

      def current_user_expense_lines
        scope = current_user.expense_lines.joins(receipt: :user)
          .where(receipts: { designation: "business", status: "confirmed" })

        if params[:tax_year].present?
          year = params[:tax_year].to_i
          scope = scope.where(receipts: { transaction_date: Date.new(year, 1, 1)..Date.new(year, 12, 31) })
        end

        scope
      end
    end
  end
end
