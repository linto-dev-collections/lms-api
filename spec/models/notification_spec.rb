require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:notification_type) }

    it "validates inclusion of notification_type" do
      notification = build(:notification, notification_type: "invalid")
      expect(notification).not_to be_valid
    end

    it "accepts valid notification_type" do
      %w[course_approved course_rejected new_enrollment enrollment_created certificate_issued new_review].each do |type|
        notification = build(:notification, notification_type: type)
        expect(notification).to be_valid
      end
    end
  end

  describe "scopes" do
    it ".unread returns only unread notifications" do
      unread = create(:notification, :unread)
      create(:notification, :read)

      expect(described_class.unread).to eq([ unread ])
    end

    it ".newest_first orders by created_at desc" do
      old = create(:notification)
      new_one = create(:notification)

      expect(described_class.newest_first).to eq([ new_one, old ])
    end
  end

  describe "#read?" do
    it "returns true when read_at is present" do
      notification = build(:notification, :read)
      expect(notification.read?).to be true
    end

    it "returns false when read_at is nil" do
      notification = build(:notification, :unread)
      expect(notification.read?).to be false
    end
  end

  describe "#mark_as_read!" do
    it "sets read_at" do
      notification = create(:notification, :unread)
      notification.mark_as_read!
      expect(notification.read_at).to be_present
    end

    it "does not update if already read" do
      notification = create(:notification, :read)
      original_read_at = notification.read_at
      notification.mark_as_read!
      expect(notification.read_at).to eq(original_read_at)
    end
  end
end
