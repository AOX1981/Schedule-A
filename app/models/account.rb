class Account < ApplicationRecord
  belongs_to :user
  has_many :receipts, dependent: :nullify

  ACCOUNT_TYPES = %w[credit_card debit_card checking savings cash].freeze

  validates :nickname, presence: true
  validates :last4, presence: true, length: { is: 4 }, format: { with: /\A\d{4}\z/ }
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }
end
