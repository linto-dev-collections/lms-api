class Review < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :course

  # Validations
  validates :rating, presence: true,
                     numericality: {
                       only_integer: true,
                       greater_than_or_equal_to: 1,
                       less_than_or_equal_to: 5
                     }
  validates :user_id, uniqueness: { scope: :course_id, message: "は既にこのコースにレビュー投稿済みです" }

  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
end
