class Notification < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :notification_type, presence: true,
                                inclusion: {
                                  in: %w[
                                    course_approved course_rejected
                                    new_enrollment enrollment_created
                                    certificate_issued new_review
                                  ]
                                }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :newest_first, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
