module Auth
  class VerifyEmailService < ApplicationService
    param :token

    def call
      user = User.find_by_token_for(:email_verification, token)

      return Failure(:invalid_token) unless user

      if user.email_verified?
        return Failure(:already_verified)
      end

      user.verify_email!

      tokens = yield Auth::GenerateTokensService.call(user)

      Success({ user: user, **tokens })
    end
  end
end
