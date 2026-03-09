class Course < ApplicationRecord
  include AASM

  # Associations
  belongs_to :instructor, class_name: "User"
  has_many :sections, -> { order(:position) }, dependent: :destroy, inverse_of: :course
  has_many :lessons, through: :sections
  has_many :enrollments, dependent: :restrict_with_error
  has_many :students, through: :enrollments, source: :user
  has_many :reviews, dependent: :destroy

  # Enums
  enum :difficulty, { beginner: "beginner", intermediate: "intermediate", advanced: "advanced" }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, presence: true
  validates :category, presence: true, length: { maximum: 100 }
  validates :difficulty, presence: true
  validates :max_enrollment, numericality: { greater_than: 0 }, allow_nil: true

  # AASM
  aasm column: :status, requires_lock: true do
    state :draft, initial: true
    state :under_review, :published, :rejected

    event :submit_for_review, guard: :has_content? do
      transitions from: :draft, to: :under_review
    end

    event :approve do
      transitions from: :under_review, to: :published
    end

    event :reject do
      transitions from: :under_review, to: :rejected
    end

    event :revise do
      transitions from: :rejected, to: :draft
    end

    event :unpublish do
      transitions from: :published, to: :draft
    end
  end

  private

  def has_content?
    sections.joins(:lessons).exists?
  end
end
