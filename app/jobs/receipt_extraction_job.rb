class ReceiptExtractionJob < ApplicationJob
  queue_as :default

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    ReceiptExtractionService.new(receipt).extract!
  end
end
