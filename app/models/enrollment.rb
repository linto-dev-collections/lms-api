class Enrollment < ApplicationRecord
  include AASM

  # Associations
  belongs_to :user
  belongs_to :course
  has_many :lesson_progresses, dependent: :destroy
  has_one :certificate, dependent: :restrict_with_error

  # Validations
  validates :user_id, uniqueness: { scope: :course_id, message: "は既にこのコースに受講登録済みです" }
  validates :enrolled_at, presence: true

  # AASM
  aasm column: :status, requires_lock: true do
    state :pending, initial: true
    state :active, :completed, :suspended

    event :activate, guard: :course_published? do
      transitions from: :pending, to: :active
    end

    event :complete, guard: :all_lessons_completed? do
      transitions from: :active, to: :completed
    end

    event :suspend do
      transitions from: :active, to: :suspended
    end

    event :resume, guard: :course_published? do
      transitions from: :suspended, to: :active
    end
  end

  private

  def course_published?
    course.aasm.current_state == :published
  end

  def all_lessons_completed?
    total = course.lessons.count
    total.positive? && lesson_progresses.where(status: "completed").count == total
  end
end
