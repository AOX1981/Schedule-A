class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  TOKEN_EXPIRY = 30.days

  def self.generate_for(user)
    raw_token = SecureRandom.urlsafe_base64(32)
    token = create!(
      user: user,
      token_digest: Digest::SHA256.hexdigest(raw_token),
      expires_at: TOKEN_EXPIRY.from_now
    )
    [token, raw_token]
  end

  def self.find_by_raw_token(raw_token)
    return nil if raw_token.blank?
    digest = Digest::SHA256.hexdigest(raw_token)
    active.find_by(token_digest: digest)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def expired?
    expires_at < Time.current
  end

  def revoked?
    revoked_at.present?
  end
end
