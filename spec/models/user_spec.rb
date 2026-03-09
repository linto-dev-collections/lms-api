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
end
