require "rails_helper"

RSpec.describe Enrollments::CompleteService do
  let(:course) { create(:course, :published) }
  let(:section) { create(:section, course: course) }
  let!(:lesson) { create(:lesson, section: section) }
  let(:enrollment) { create(:enrollment, :active, course: course) }

  describe "#call" do
    before do
      create(:lesson_progress, :completed, enrollment: enrollment, lesson: lesson)
    end

    it "completes enrollment and issues certificate" do
      result = described_class.call(enrollment)
      expect(result).to be_success
      expect(enrollment.reload.status).to eq("completed")
      expect(result.value!).to be_a(Certificate)
      expect(result.value!.status).to eq("issued")
    end

    it "fails when enrollment cannot complete" do
      pending_enrollment = create(:enrollment, course: course)
      result = described_class.call(pending_enrollment)
      expect(result).to be_failure
      expect(result.failure).to eq(:cannot_complete)
    end
  end
end
