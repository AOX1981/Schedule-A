class ReceiptExtractionService
  STORE_NAME_PATTERNS = [
    /^(.+?)(?:\s+#\d+|\s+store)/i,
    /^(.+?)(?:\n|\r)/
  ].freeze

  DATE_PATTERNS = [
    /(\d{1,2}\/\d{1,2}\/\d{2,4})/,
    /(\d{4}-\d{2}-\d{2})/,
    /(\w+\s+\d{1,2},?\s+\d{4})/
  ].freeze

  TIME_PATTERNS = [
    /(\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM)?)/i
  ].freeze

  AMOUNT_PATTERN = /\$?\s*(\d+\.\d{2})/

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

    extracted
  end

  private

  def perform_ocr
    # Server-side OCR placeholder
    # In production, integrate with Tesseract, Google Vision, or AWS Textract
    # For MVP, return stored raw text or empty string
    @receipt.raw_ocr_text || ""
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
    totals = text.scan(/(?:total|amount\s*due|balance)\s*:?\s*\$?\s*(\d+\.\d{2})/i)
    return nil if totals.empty?
    totals.last[0].to_f
  end

  def extract_line_items(text)
    items = []
    text.scan(/(.+?)\s+\$?\s*(\d+\.\d{2})/).each do |name, price|
      name = name.strip
      next if name.match?(/total|tax|subtotal|change|cash|credit|debit/i)
      next if name.length < 2
      items << { item: name, cost: price.to_f }
    end
    items
  end
end
