require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:courses).with_foreign_key(:instructor_id) }
    it { is_expected.to have_many(:enrollments).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:refresh_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_one(:notification_preference).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to have_secure_password }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:role).backed_by_column_of_type(:string).with_values(admin: "admin", instructor: "instructor", student: "student") }
  end

  describe "normalizations" do
    it "normalizes email to lowercase and strips whitespace" do
      user = build(:user, email: "  Test@Example.COM  ")
      user.validate
      expect(user.email).to eq("test@example.com")
    end
  end

  describe "EmailVerifiable" do
    describe "#email_verified?" do
      it "returns false when email_verified_at is nil" do
        user = build(:user, email_verified_at: nil)
        expect(user.email_verified?).to be false
      end

      it "returns true when email_verified_at is present" do
        user = build(:user, email_verified_at: Time.current)
        expect(user.email_verified?).to be true
      end
    end

    describe "#verify_email!" do
      it "sets email_verified_at" do
        user = create(:user, email_verified_at: nil)
        expect { user.verify_email! }
          .to change { user.reload.email_verified_at }.from(nil)
        expect(user.email_verified_at).to be_within(1.second).of(Time.current)
      end
    end

    describe "#email_verification_token" do
      it "generates a token that can find the user" do
        user = create(:user, email_verified_at: nil)
        token = user.email_verification_token
        expect(User.find_by_token_for(:email_verification, token)).to eq(user)
      end

      it "returns nil after email is verified (token auto-invalidation)" do
        user = create(:user, email_verified_at: nil)
        token = user.email_verification_token
        user.verify_email!
        expect(User.find_by_token_for(:email_verification, token)).to be_nil
      end
    end

    describe "#can_resend_verification_email?" do
      it "returns true when email_verification_sent_at is nil" do
        user = build(:user, email_verification_sent_at: nil)
        expect(user.can_resend_verification_email?).to be true
      end

      it "returns false within the resend interval" do
        user = build(:user, email_verification_sent_at: 30.seconds.ago)
        expect(user.can_resend_verification_email?).to be false
      end

      it "returns true after the resend interval" do
        user = build(:user, email_verification_sent_at: 61.seconds.ago)
        expect(user.can_resend_verification_email?).to be true
      end
    end
  end
end
