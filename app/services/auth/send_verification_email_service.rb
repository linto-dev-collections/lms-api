module Auth
  class SendVerificationEmailService < ApplicationService
    param :user

    def call
      unless user.can_resend_verification_email?
        return Failure(:rate_limited)
      end

      if user.email_verified?
        return Failure(:already_verified)
      end

      token = user.email_verification_token
      EmailVerificationMailer.verify(user, token).deliver_later
      user.record_verification_email_sent!

      Success(true)
    end
  end
end
