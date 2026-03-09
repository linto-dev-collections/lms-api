module Reviews
  class CreateForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :rating, :integer
    attribute :comment, :string
    attribute :anonymous, :boolean, default: false

    validates :rating, presence: true,
                       numericality: {
                         only_integer: true,
                         greater_than_or_equal_to: 1,
                         less_than_or_equal_to: 5
                       }
  end
end
