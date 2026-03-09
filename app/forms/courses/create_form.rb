module Courses
  class CreateForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :title, :string
    attribute :description, :string
    attribute :category, :string
    attribute :difficulty, :string
    attribute :max_enrollment, :integer

    before_validation :normalize_attributes

    validates :title, presence: true, length: { maximum: 200 }
    validates :description, presence: true
    validates :category, presence: true
    validates :difficulty, presence: true,
                           inclusion: { in: %w[beginner intermediate advanced] }
    validates :max_enrollment, numericality: { greater_than: 0 }, allow_nil: true

    private

    def normalize_attributes
      self.title = title&.strip
      self.category = category&.strip&.downcase
    end
  end
end
