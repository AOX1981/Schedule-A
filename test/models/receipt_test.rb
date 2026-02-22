require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  test "auto-assigns receipt number" do
    receipt = Receipt.create!(user: users(:default), designation: "business")
    assert receipt.receipt_number > 1000
  end

  test "validates designation" do
    receipt = Receipt.new(user: users(:default), designation: "invalid")
    assert_not receipt.valid?
  end

  test "confirm changes status" do
    receipt = receipts(:pending_receipt)
    receipt.confirm!
    assert_equal "confirmed", receipt.status
  end

  test "scopes: business" do
    assert Receipt.business.all? { |r| r.designation == "business" }
  end
end
