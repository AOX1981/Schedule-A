require "csv"

class ExportService
  def self.generate_schedule_c_csv(grouped_data)
    CSV.generate do |csv|
      csv << ["Schedule C Line", "Category", "Total Writeoff"]
      ExpenseLine::SCHEDULE_C_CATEGORIES.each do |category, line_num|
        amount = (grouped_data[category] || 0).to_f.round(2)
        next if amount.zero?
        csv << [line_num, category.titleize, amount]
      end
      csv << []
      csv << ["", "Grand Total", grouped_data.values.sum.to_f.round(2)]
    end
  end

  def self.generate_schedule_c_pdf(grouped_data, user, tax_year)
    tax_year ||= Date.current.year

    Prawn::Document.new do |pdf|
      pdf.text "Schedule C - Expense Summary", size: 20, style: :bold
      pdf.move_down 10
      pdf.text "Prepared for: #{user.full_name}", size: 12
      pdf.text "Tax Year: #{tax_year}", size: 12
      pdf.text "Generated: #{Time.current.strftime('%B %d, %Y')}", size: 10
      pdf.move_down 20

      table_data = [["Line #", "Category", "Deduction Amount"]]
      grand_total = 0

      ExpenseLine::SCHEDULE_C_CATEGORIES.each do |category, line_num|
        amount = (grouped_data[category] || 0).to_f.round(2)
        next if amount.zero?
        table_data << [line_num.to_s, category.titleize, "$#{'%.2f' % amount}"]
        grand_total += amount
      end

      table_data << ["", "Grand Total", "$#{'%.2f' % grand_total}"]

      pdf.table(table_data, header: true, width: pdf.bounds.width) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "DDDDDD"
        t.row(-1).font_style = :bold
        t.columns(2).align = :right
      end
    end.render
  end

  def self.generate_expense_lines_csv(lines)
    CSV.generate do |csv|
      csv << [
        "Display ID", "Date", "Time", "Store", "City", "State",
        "Item", "Cost", "Acct Last4", "Tax Category",
        "Writeoff %", "Writeoff Value"
      ]

      lines.each do |line|
        receipt = line.receipt
        csv << [
          line.transaction_display_id,
          receipt.transaction_date,
          receipt.transaction_time,
          receipt.store_name,
          receipt.city,
          receipt.state,
          line.item,
          line.cost.to_f.round(2),
          receipt.account&.last4,
          line.tax_category,
          line.writeoff_percent.to_f.round(2),
          line.writeoff_value.to_f.round(2)
        ]
      end
    end
  end
end
