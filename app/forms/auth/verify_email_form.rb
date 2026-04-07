module Auth
  class VerifyEmailForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :token, :string

    validates :token, presence: true
  end
end
