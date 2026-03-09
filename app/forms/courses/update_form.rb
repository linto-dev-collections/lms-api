module Courses
  class UpdateForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :title, :string
    attribute :description, :string
    attribute :category, :string
    attribute :difficulty, :string
    attribute :max_enrollment, :integer

    before_validation :normalize_attributes

    validates :title, length: { maximum: 200 }, allow_nil: true
    validates :difficulty, inclusion: { in: %w[beginner intermediate advanced] }, allow_nil: true
    validates :max_enrollment, numericality: { greater_than: 0 }, allow_nil: true

    # nil 値を除外して更新対象のみ返す
    def attributes_for_update
      attributes.compact
    end

    private

    def normalize_attributes
      self.title = title&.strip
      self.category = category&.strip&.downcase
    end
  end
end
