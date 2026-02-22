class User < ApplicationRecord
  has_secure_password

  has_many :api_tokens, dependent: :destroy
  has_many :business_profiles, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :expense_lines, dependent: :destroy
  has_many :audit_logs, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase
  end
end
