require "rails_helper"

RSpec.describe EnrollmentNotifier do
  let(:instructor) { create(:user, :instructor) }
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published, instructor: instructor) }
  let(:enrollment) { create(:enrollment, :active, user: student, course: course) }

  describe "#new_enrollment" do
    it "sends a notification to the instructor" do
      expect {
        described_class.with(enrollment: enrollment).new_enrollment.notify_now
      }.to have_sent_notification

      delivery = AbstractNotifier::Testing::Driver.deliveries.last
      expect(delivery[:to]).to eq(instructor)
      expect(delivery[:notification_type]).to eq("new_enrollment")
      expect(delivery[:params][:student_name]).to eq(student.name)
    end
  end

  describe "#enrollment_created" do
    it "sends a notification to the student" do
      expect {
        described_class.with(enrollment: enrollment).enrollment_created.notify_now
      }.to have_sent_notification

      delivery = AbstractNotifier::Testing::Driver.deliveries.last
      expect(delivery[:to]).to eq(student)
      expect(delivery[:notification_type]).to eq("enrollment_completed")
    end
  end

  describe "#new_review" do
    let(:review) { create(:review, user: student, course: course) }

    it "sends a notification to the instructor" do
      expect {
        described_class.with(review: review).new_review.notify_now
      }.to have_sent_notification

      delivery = AbstractNotifier::Testing::Driver.deliveries.last
      expect(delivery[:to]).to eq(instructor)
      expect(delivery[:notification_type]).to eq("new_review")
      expect(delivery[:params][:rating]).to eq(review.rating)
    end
  end
end
