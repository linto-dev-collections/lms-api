class RefreshToken < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :token_digest, presence: true, uniqueness: true
  validates :jti, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Scopes
  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
