require "rails_helper"

RSpec.describe NotificationPreference, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:notification_preference) }

    it { is_expected.to validate_uniqueness_of(:user_id) }
  end

  describe "default preferences" do
    it "has in_app notifications enabled by default" do
      pref = described_class.new
      expect(pref.preferences.in_app.course_approved).to be true
      expect(pref.preferences.in_app.new_enrollment).to be true
    end

    it "has email notifications disabled by default" do
      pref = described_class.new
      expect(pref.preferences.email.course_approved).to be false
      expect(pref.preferences.email.new_enrollment).to be false
    end
  end

  describe "#enabled?" do
    let(:pref) { create(:notification_preference) }

    it "returns true for enabled in_app notification" do
      expect(pref.enabled?(:in_app, :course_approved)).to be true
    end

    it "returns false for disabled email notification" do
      expect(pref.enabled?(:email, :course_approved)).to be false
    end

    it "returns false for invalid channel" do
      expect(pref.enabled?(:sms, :course_approved)).to be false
    end

    it "returns false for invalid notification type" do
      expect(pref.enabled?(:in_app, :invalid_type)).to be false
    end
  end
end
