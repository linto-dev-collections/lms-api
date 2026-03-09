require "rails_helper"

RSpec.describe InAppNotificationDriver do
  let(:driver) { described_class.new }
  let(:user) { create(:user) }

  describe "#call" do
    it "creates a notification record" do
      payload = {
        to: user,
        notification_type: "new_enrollment",
        params: { course_title: "テストコース" }
      }

      expect { driver.call(payload) }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.user).to eq(user)
      expect(notification.notification_type).to eq("new_enrollment")
      expect(notification.params["course_title"]).to eq("テストコース")
    end

    it "skips when recipient is nil" do
      payload = {
        to: nil,
        notification_type: "new_enrollment",
        params: {}
      }

      expect { driver.call(payload) }.not_to change(Notification, :count)
    end

    it "skips when preference is disabled" do
      pref = create(:notification_preference, user: user)
      channel_settings = pref.preferences.in_app
      channel_settings.new_enrollment = false
      pref.save!

      payload = {
        to: user,
        notification_type: "new_enrollment",
        params: { course_title: "テストコース" }
      }

      expect { driver.call(payload) }.not_to change(Notification, :count)
    end
  end
end
