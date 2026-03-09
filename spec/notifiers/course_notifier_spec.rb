require "rails_helper"

RSpec.describe CourseNotifier do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, :published, instructor: instructor) }

  describe "#course_approved" do
    it "sends a notification to the instructor" do
      expect {
        described_class.with(course: course).course_approved.notify_now
      }.to have_sent_notification

      delivery = AbstractNotifier::Testing::Driver.deliveries.last
      expect(delivery[:to]).to eq(instructor)
      expect(delivery[:notification_type]).to eq("course_approved")
    end
  end

  describe "#course_rejected" do
    it "sends a notification with reason to the instructor" do
      expect {
        described_class.with(course: course, reason: "内容が不十分").course_rejected.notify_now
      }.to have_sent_notification

      delivery = AbstractNotifier::Testing::Driver.deliveries.last
      expect(delivery[:to]).to eq(instructor)
      expect(delivery[:notification_type]).to eq("course_rejected")
      expect(delivery[:params][:reason]).to eq("内容が不十分")
    end
  end
end
