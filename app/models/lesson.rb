class Lesson < ApplicationRecord
  # Associations
  belongs_to :section, inverse_of: :lessons
  has_one :course, through: :section
  has_many :lesson_progresses, dependent: :destroy

  # Enums
  enum :content_type, { text: "text", video: "video", quiz: "quiz" }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :content_type, presence: true
  validates :duration_minutes, presence: true,
                               numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true,
                       numericality: { greater_than_or_equal_to: 0 }
end
