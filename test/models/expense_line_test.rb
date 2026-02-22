require "test_helper"

class ExpenseLineTest < ActiveSupport::TestCase
  test "computes writeoff value" do
    line = expense_lines(:default)
    line.writeoff_percent = 50.0
    line.save!
    assert_equal 6.50, line.writeoff_value.to_f
  end

  test "requires item" do
    line = ExpenseLine.new(receipt: receipts(:default), user: users(:default), cost: 10.0)
    assert_not line.valid?
    assert line.errors[:item].present?
  end

  test "requires valid tax category" do
    line = ExpenseLine.new(
      receipt: receipts(:default), user: users(:default),
      item: "Test", cost: 10.0, tax_category: "invalid"
    )
    assert_not line.valid?
    assert line.errors[:tax_category].present?
  end

  test "allows nil tax category" do
    line = ExpenseLine.new(
      receipt: receipts(:default), user: users(:default),
      item: "Test", cost: 10.0, tax_category: nil
    )
    assert line.valid?
  end

  test "auto-assigns line number" do
    line = ExpenseLine.create!(
      receipt: receipts(:pending_receipt), user: users(:default),
      item: "Auto Numbered", cost: 5.0
    )
    assert_equal 1, line.line_number
  end

  test "auto-assigns display id" do
    line = ExpenseLine.create!(
      receipt: receipts(:pending_receipt), user: users(:default),
      item: "Auto Display", cost: 5.0
    )
    assert_equal "#{receipts(:pending_receipt).receipt_number}.1", line.transaction_display_id
  end
end
