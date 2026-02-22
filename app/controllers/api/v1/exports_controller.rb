module Api
  module V1
    class ExportsController < BaseController
      def schedule_c_csv
        lines = schedule_c_data
        csv_data = ExportService.generate_schedule_c_csv(lines)

        send_data csv_data,
          filename: "schedule_c_#{params[:tax_year] || Date.current.year}.csv",
          type: "text/csv",
          disposition: "attachment"
      end

      def schedule_c_pdf
        lines = schedule_c_data
        pdf_data = ExportService.generate_schedule_c_pdf(lines, current_user, params[:tax_year])

        send_data pdf_data,
          filename: "schedule_c_#{params[:tax_year] || Date.current.year}.pdf",
          type: "application/pdf",
          disposition: "attachment"
      end

      def expense_lines_csv
        lines = current_user.expense_lines
          .joins(:receipt)
          .includes(receipt: :account)
          .where(receipts: { designation: "business", status: "confirmed" })
          .order("receipts.transaction_date", :line_number)

        if params[:tax_year].present?
          year = params[:tax_year].to_i
          lines = lines.where(receipts: { transaction_date: Date.new(year, 1, 1)..Date.new(year, 12, 31) })
        end

        csv_data = ExportService.generate_expense_lines_csv(lines)

        send_data csv_data,
          filename: "expense_lines_#{params[:tax_year] || Date.current.year}.csv",
          type: "text/csv",
          disposition: "attachment"
      end

      private

      def schedule_c_data
        scope = current_user.expense_lines
          .joins(:receipt)
          .where(receipts: { designation: "business", status: "confirmed" })
          .where.not(tax_category: nil)

        if params[:tax_year].present?
          year = params[:tax_year].to_i
          scope = scope.where(receipts: { transaction_date: Date.new(year, 1, 1)..Date.new(year, 12, 31) })
        end

        scope.group(:tax_category).sum(:writeoff_value)
      end
    end
  end
end
