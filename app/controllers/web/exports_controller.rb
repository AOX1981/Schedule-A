module Web
  class ExportsController < ApplicationController
    before_action :require_login

    def index
      @tax_year = (params[:tax_year] || Date.current.year).to_i
    end

    def schedule_c_csv
      year = (params[:tax_year] || Date.current.year).to_i
      data = schedule_c_data(year)
      csv = ExportService.generate_schedule_c_csv(data)
      send_data csv, filename: "schedule_c_#{year}.csv", type: "text/csv", disposition: "attachment"
    end

    def schedule_c_pdf
      year = (params[:tax_year] || Date.current.year).to_i
      data = schedule_c_data(year)
      pdf = ExportService.generate_schedule_c_pdf(data, current_user, year)
      send_data pdf, filename: "schedule_c_#{year}.pdf", type: "application/pdf", disposition: "attachment"
    end

    def expense_lines_csv
      year = (params[:tax_year] || Date.current.year).to_i
      lines = current_user.expense_lines
        .joins(:receipt)
        .includes(receipt: :account)
        .where(receipts: { designation: "business", status: "confirmed",
                           transaction_date: Date.new(year, 1, 1)..Date.new(year, 12, 31) })
        .order("receipts.transaction_date", :line_number)

      csv = ExportService.generate_expense_lines_csv(lines)
      send_data csv, filename: "expense_lines_#{year}.csv", type: "text/csv", disposition: "attachment"
    end

    private

    def schedule_c_data(year)
      current_user.expense_lines
        .joins(:receipt)
        .where(receipts: { designation: "business", status: "confirmed",
                           transaction_date: Date.new(year, 1, 1)..Date.new(year, 12, 31) })
        .where.not(tax_category: nil)
        .group(:tax_category)
        .sum(:writeoff_value)
    end
  end
end
