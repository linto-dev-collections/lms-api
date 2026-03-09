require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:refresh_token) }

    it { is_expected.to validate_presence_of(:token_digest) }
    it { is_expected.to validate_uniqueness_of(:token_digest) }
    it { is_expected.to validate_presence_of(:jti) }
    it { is_expected.to validate_uniqueness_of(:jti) }
    it { is_expected.to validate_presence_of(:expires_at) }
  end

  describe "scopes" do
    it ".active returns non-revoked, non-expired tokens" do
      active = create(:refresh_token)
      create(:refresh_token, :expired)
      create(:refresh_token, :revoked)

      expect(described_class.active).to eq([ active ])
    end
  end

  describe "#revoked?" do
    it "returns true when revoked_at is present" do
      token = build(:refresh_token, :revoked)
      expect(token.revoked?).to be true
    end

    it "returns false when revoked_at is nil" do
      token = build(:refresh_token)
      expect(token.revoked?).to be false
    end
  end

  describe "#expired?" do
    it "returns true when expired" do
      token = build(:refresh_token, :expired)
      expect(token.expired?).to be true
    end

    it "returns false when not expired" do
      token = build(:refresh_token)
      expect(token.expired?).to be false
    end
  end

  describe "#revoke!" do
    it "sets revoked_at to current time" do
      token = create(:refresh_token)
      token.revoke!
      expect(token.revoked_at).to be_present
    end
  end
end
