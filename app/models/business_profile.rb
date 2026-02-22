class BusinessProfile < ApplicationRecord
  belongs_to :user
  has_many :receipts, dependent: :nullify

  BUSINESS_TYPES = %w[sole_proprietorship single_member_llc].freeze

  validates :business_name, presence: true
  validates :tax_year, presence: true,
                       numericality: { only_integer: true, greater_than: 2000, less_than: 2100 }
  validates :tax_year, uniqueness: { scope: :user_id, message: "already has a profile for this year" }
  validates :business_type, inclusion: { in: BUSINESS_TYPES }
end
