module EmailVerifiable
  extend ActiveSupport::Concern

  included do
    generates_token_for :email_verification,
                        expires_in: AuthConfig.instance.email_verification_expiry.seconds do
      email_verified_at.to_s
    end
  end

  def verify_email!
    update!(email_verified_at: Time.current)
  end

  def email_verified?
    email_verified_at.present?
  end

  def can_resend_verification_email?
    return true if email_verification_sent_at.nil?

    email_verification_sent_at <
      AuthConfig.instance.email_verification_resend_interval.seconds.ago
  end

  def record_verification_email_sent!
    update!(email_verification_sent_at: Time.current)
  end

  def email_verification_token
    generate_token_for(:email_verification)
  end
end
