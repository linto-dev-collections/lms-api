class Section < ApplicationRecord
  # Associations
  belongs_to :course, inverse_of: :sections
  has_many :lessons, -> { order(:position) }, dependent: :destroy, inverse_of: :section

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :position, presence: true,
                       numericality: { greater_than_or_equal_to: 0 }
end
