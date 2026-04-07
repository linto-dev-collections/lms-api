require "rails_helper"

RSpec.describe EmailVerificationMailer, type: :mailer do
  describe "#verify" do
    let(:user) { create(:user) }
    let(:token) { "test_verification_token" }

    subject(:mail) { described_class.verify(user, token) }

    it "sends to the user's email" do
      expect(mail.to).to eq([ user.email ])
    end

    it "sets the correct subject" do
      expect(mail.subject).to eq("【LMS】メールアドレスの確認")
    end

    it "includes the token in the body" do
      expect(mail.body.encoded).to include(token)
    end

    it "includes the user's name in the body" do
      expect(mail.body.encoded).to include(user.name)
    end
  end
end
