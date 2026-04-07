require "rails_helper"

RSpec.describe Auth::VerifyEmailService do
  describe ".call" do
    let(:user) { create(:user, email_verified_at: nil) }

    it "verifies the user and returns tokens" do
      token = user.email_verification_token
      result = described_class.call(token)

      expect(result).to be_success
      expect(result.value![:user]).to eq(user)
      expect(result.value![:access_token]).to be_present
      expect(result.value![:refresh_token]).to be_present
      expect(user.reload.email_verified?).to be true
    end

    it "returns Failure(:invalid_token) for invalid token" do
      result = described_class.call("invalid_token")

      expect(result).to be_failure
      expect(result.failure).to eq(:invalid_token)
    end

    it "returns Failure(:already_verified) when user is already verified" do
      user.update!(email_verified_at: Time.current)
      token = user.generate_token_for(:email_verification)

      result = described_class.call(token)

      expect(result).to be_failure
      expect(result.failure).to eq(:already_verified)
    end

    it "invalidates token after verification (single use)" do
      token = user.email_verification_token

      first_result = described_class.call(token)
      expect(first_result).to be_success

      second_result = described_class.call(token)
      expect(second_result).to be_failure
      expect(second_result.failure).to eq(:invalid_token)
    end
  end
end
