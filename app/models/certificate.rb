class Certificate < ApplicationRecord
  include AASM

  # Associations
  belongs_to :enrollment
  has_one :user, through: :enrollment
  has_one :course, through: :enrollment

  # Validations
  validates :enrollment_id, uniqueness: true
  validates :certificate_number, presence: true, uniqueness: true

  # AASM
  aasm column: :status do
    state :pending, initial: true
    state :issued, :revoked

    event :issue do
      transitions from: :pending, to: :issued
    end

    event :revoke do
      transitions from: :issued, to: :revoked
    end
  end
end
