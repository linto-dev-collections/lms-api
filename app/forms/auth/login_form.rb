module Auth
  class LoginForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :email, :string
    attribute :password, :string

    before_validation :normalize_attributes

    validates :email, presence: true
    validates :password, presence: true

    private

    def normalize_attributes
      self.email = email&.strip&.downcase
    end
  end
end
