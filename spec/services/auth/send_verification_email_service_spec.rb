require "rails_helper"

RSpec.describe Auth::SendVerificationEmailService do
  describe ".call" do
    let(:user) { create(:user, email_verified_at: nil, email_verification_sent_at: nil) }

    it "sends a verification email and records sent_at" do
      expect {
        described_class.call(user)
      }.to have_enqueued_mail(EmailVerificationMailer, :verify)

      expect(user.reload.email_verification_sent_at).to be_present
    end

    it "returns Failure(:rate_limited) when called within the resend interval" do
      user.update!(email_verification_sent_at: 30.seconds.ago)

      result = described_class.call(user)
      expect(result).to be_failure
      expect(result.failure).to eq(:rate_limited)
    end

    it "returns Failure(:already_verified) when user is already verified" do
      user.update!(email_verified_at: Time.current)

      result = described_class.call(user)
      expect(result).to be_failure
      expect(result.failure).to eq(:already_verified)
    end
  end
end
