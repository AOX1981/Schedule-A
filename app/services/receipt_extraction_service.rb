class ReceiptExtractionService
  DATE_PATTERNS = [
    /(\d{1,2}\/\d{1,2}\/\d{2,4})/,
    /(\d{4}-\d{2}-\d{2})/,
    /(\w+\s+\d{1,2},?\s+\d{4})/
  ].freeze

  TIME_PATTERNS = [
    /(\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM)?)/i
  ].freeze

  def initialize(receipt)
    @receipt = receipt
  end

  def extract!
    return unless @receipt.image.attached?

    text = perform_ocr
    @receipt.update!(raw_ocr_text: text)

    extracted = parse_text(text)
    @receipt.update!(
      extracted_data: extracted,
      store_name: extracted[:store_name] || @receipt.store_name,
      transaction_date: extracted[:date] || @receipt.transaction_date,
      transaction_time: extracted[:time] || @receipt.transaction_time,
      total_amount: extracted[:total] || @receipt.total_amount,
      status: "extracted"
    )

    create_expense_lines(extracted[:line_items]) if extracted[:line_items].present?

    extracted
  end

  private

  def perform_ocr
    blob = @receipt.image.blob
    tempfile = Tempfile.new(["receipt", extension_for(blob.content_type)])
    begin
      tempfile.binmode
      tempfile.write(blob.download)
      tempfile.rewind

      if blob.content_type == "application/pdf"
        extract_text_from_pdf(tempfile.path)
      else
        image = RTesseract.new(tempfile.path)
        image.to_s.strip
      end
    ensure
      tempfile.close
      tempfile.unlink
    end
  rescue => e
    Rails.logger.error("OCR failed for receipt #{@receipt.id}: #{e.message}")
    ""
  end

  def extract_text_from_pdf(pdf_path)
    # Convert first page of PDF to image, then OCR
    png_temp = Tempfile.new(["receipt_page", ".png"])
    begin
      system("convert", "-density", "300", "#{pdf_path}[0]", "-quality", "100", png_temp.path)
      if File.size?(png_temp.path)
        image = RTesseract.new(png_temp.path)
        image.to_s.strip
      else
        ""
      end
    ensure
      png_temp.close
      png_temp.unlink
    end
  end

  def extension_for(content_type)
    case content_type
    when "image/jpeg" then ".jpg"
    when "image/png" then ".png"
    when "image/gif" then ".gif"
    when "image/webp" then ".webp"
    when "application/pdf" then ".pdf"
    else ".jpg"
    end
  end

  def parse_text(text)
    return {} if text.blank?

    {
      store_name: extract_store_name(text),
      date: extract_date(text),
      time: extract_time(text),
      total: extract_total(text),
      line_items: extract_line_items(text)
    }.compact
  end

  def extract_store_name(text)
    lines = text.split("\n").map(&:strip).reject(&:empty?)
    lines.first&.strip
  end

  def extract_date(text)
    DATE_PATTERNS.each do |pattern|
      match = text.match(pattern)
      next unless match
      begin
        return Date.parse(match[1])
      rescue Date::Error
        next
      end
    end
    nil
  end

  def extract_time(text)
    TIME_PATTERNS.each do |pattern|
      match = text.match(pattern)
      return match[1] if match
    end
    nil
  end

  def extract_total(text)
    totals = text.scan(/(?:total|amount\s*due|balance|grand\s*total)\s*:?\s*\$?\s*(\d+\.\d{2})/i)
    return nil if totals.empty?
    totals.last[0].to_f
  end

  def extract_line_items(text)
    items = []
    text.scan(/(.+?)\s+\$?\s*(\d+\.\d{2})/).each do |name, price|
      name = name.strip.gsub(/[^\w\s\-\/&]/, "").strip
      next if name.match?(/total|tax|subtotal|change|cash|credit|debit|visa|mastercard|amex|balance|tendered/i)
      next if name.length < 2
      items << { item: name, cost: price.to_f }
    end
    items
  end

  def create_expense_lines(line_items)
    return if line_items.blank?

    line_items.each do |li|
      @receipt.expense_lines.create!(
        user: @receipt.user,
        item: li[:item],
        cost: li[:cost],
        writeoff_percent: 100
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn("Could not create expense line: #{e.message}")
    end
  end
end
