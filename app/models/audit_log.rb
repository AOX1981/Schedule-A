class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true

  ACTIONS = %w[create update delete confirm].freeze

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :for_record, ->(record) { where(auditable: record) }
  scope :recent, -> { order(created_at: :desc) }

  def self.log!(user:, auditable:, action:, changed_fields: {}, ip_address: nil)
    create!(
      user: user,
      auditable: auditable,
      action: action,
      changed_fields: changed_fields,
      ip_address: ip_address
    )
  end
end
