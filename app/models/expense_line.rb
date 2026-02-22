class ExpenseLine < ApplicationRecord
  belongs_to :receipt
  belongs_to :user

  SCHEDULE_C_CATEGORIES = {
    "advertising" => 8,
    "car_and_truck" => 9,
    "commissions_and_fees" => 10,
    "contract_labor" => 11,
    "depletion" => 12,
    "depreciation" => 13,
    "employee_benefit_programs" => 14,
    "insurance" => 15,
    "interest_mortgage" => 16,
    "interest_other" => 17,
    "legal_and_professional" => 18,
    "office_expense" => 19,
    "pension_profit_sharing" => 20,
    "rent_vehicles" => 20,
    "rent_other" => 21,
    "repairs_and_maintenance" => 22,
    "supplies" => 23,
    "taxes_and_licenses" => 24,
    "travel" => 25,
    "deductible_meals" => 26,
    "utilities" => 27,
    "wages" => 28,
    "other_expenses" => 29
  }.freeze

  validates :item, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :line_number, presence: true, uniqueness: { scope: :receipt_id }
  validates :transaction_display_id, presence: true, uniqueness: true
  validates :writeoff_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :tax_category, inclusion: { in: SCHEDULE_C_CATEGORIES.keys }, allow_nil: true

  before_validation :assign_line_number, on: :create
  before_validation :assign_display_id, on: :create
  before_save :compute_writeoff_value

  private

  def assign_line_number
    return if line_number.present?
    max = receipt.expense_lines.maximum(:line_number) || 0
    self.line_number = max + 1
  end

  def assign_display_id
    return if transaction_display_id.present?
    self.transaction_display_id = "#{receipt.receipt_number}.#{line_number}"
  end

  def compute_writeoff_value
    return unless cost.present? && writeoff_percent.present?
    self.writeoff_value = (cost * writeoff_percent / 100.0).round(2)
  end
end
