class Receipt < ApplicationRecord
  belongs_to :user
  belongs_to :business_profile, optional: true
  belongs_to :account, optional: true
  has_many :expense_lines, dependent: :destroy
  has_one_attached :image

  DESIGNATIONS = %w[business personal].freeze
  SOURCES = %w[upload email_forward].freeze
  STATUSES = %w[pending extracted confirmed].freeze

  validates :receipt_number, presence: true, uniqueness: { scope: :user_id }
  validates :designation, inclusion: { in: DESIGNATIONS }
  validates :source, inclusion: { in: SOURCES }
  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :assign_receipt_number, on: :create

  scope :business, -> { where(designation: "business") }
  scope :confirmed, -> { where(status: "confirmed") }

  def confirm!
    update!(status: "confirmed")
  end

  private

  def assign_receipt_number
    return if receipt_number.present?
    max = user.receipts.maximum(:receipt_number) || 1000
    self.receipt_number = max + 1
  end
end
