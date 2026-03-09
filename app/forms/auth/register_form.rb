module Auth
  class RegisterForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :email, :string
    attribute :name, :string
    attribute :password, :string
    attribute :password_confirmation, :string
    attribute :role, :string

    before_validation :normalize_attributes

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :name, presence: true, length: { maximum: 100 }
    validates :password, presence: true, length: { minimum: 8 }
    validates :password_confirmation, presence: true
    validates :role, inclusion: { in: %w[student instructor] }, allow_blank: true
    validate :passwords_match

    private

    def normalize_attributes
      self.email = email&.strip&.downcase
      self.name = name&.strip
    end

    def passwords_match
      return if password.blank? || password_confirmation.blank?

      errors.add(:password_confirmation, "がパスワードと一致しません") if password != password_confirmation
    end
  end
end
