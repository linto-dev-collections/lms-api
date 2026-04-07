module Auth
  class ResendVerificationForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :email, :string

    before_validation :normalize_attributes

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    private

    def normalize_attributes
      self.email = email&.strip&.downcase
    end
  end
end
