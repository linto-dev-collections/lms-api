class LessonProgress < ApplicationRecord
  # Associations
  belongs_to :enrollment
  belongs_to :lesson

  # Enums
  enum :status, { not_started: "not_started", in_progress: "in_progress", completed: "completed" }

  # Validations
  validates :enrollment_id, uniqueness: { scope: :lesson_id }
  validates :status, presence: true

  # Scopes
  scope :completed, -> { where(status: :completed) }
end
