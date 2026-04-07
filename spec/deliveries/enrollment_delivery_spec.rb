require "rails_helper"

RSpec.describe EnrollmentDelivery, type: :delivery do
  let(:instructor) { create(:user, :instructor) }
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published, instructor: instructor) }
  let(:enrollment) { create(:enrollment, :active, user: student, course: course) }

  describe "delivery routing" do
    context "when email is disabled (default)" do
      it "delivers via notifier line only (no mailer)" do
        expect {
          described_class.with(enrollment: enrollment).notify(:new_enrollment)
        }.to deliver_via(:notifier)
      end
    end

    context "when email is enabled" do
      before do
        pref = create(:notification_preference, user: instructor)
        pref.preferences.email.new_enrollment = true
        pref.save!
      end

      it "delivers via both notifier and mailer lines" do
        expect {
          described_class.with(enrollment: enrollment).notify(:new_enrollment)
        }.to deliver_via(:mailer, :notifier)
      end
    end
  end

  describe "delivery target" do
    it "delivers new_enrollment notification" do
      expect {
        described_class.with(enrollment: enrollment).notify(:new_enrollment)
      }.to have_delivered_to(described_class, :new_enrollment)
    end

    it "delivers enrollment_created notification" do
      expect {
        described_class.with(enrollment: enrollment).notify(:enrollment_created)
      }.to have_delivered_to(described_class, :enrollment_created)
    end
  end
end
