require "rails_helper"

RSpec.describe Enrollments::CreateService do
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published, max_enrollment: 2) }

  describe "#call" do
    it "creates an enrollment successfully" do
      result = described_class.call(student, course)
      expect(result).to be_success
      expect(result.value!).to be_a(Enrollment)
      expect(result.value!.status).to eq("pending")
    end

    it "fails when course is not published" do
      draft_course = create(:course)
      result = described_class.call(student, draft_course)
      expect(result).to be_failure
      expect(result.failure).to eq(:course_not_published)
    end

    it "fails when already enrolled" do
      create(:enrollment, user: student, course: course)
      result = described_class.call(student, course)
      expect(result).to be_failure
      expect(result.failure).to eq(:already_enrolled)
    end

    it "fails when capacity is exceeded" do
      create_list(:enrollment, 2, course: course)
      result = described_class.call(student, course)
      expect(result).to be_failure
      expect(result.failure).to eq(:capacity_exceeded)
    end

    it "fails for non-student user" do
      instructor = create(:user, :instructor)
      result = described_class.call(instructor, course)
      expect(result).to be_failure
      expect(result.failure).to eq(:not_student)
    end

    it "succeeds when max_enrollment is nil" do
      unlimited_course = create(:course, :published, max_enrollment: nil)
      result = described_class.call(student, unlimited_course)
      expect(result).to be_success
    end

    it "excludes suspended enrollments from capacity count" do
      create(:enrollment, :suspended, course: course)
      create(:enrollment, course: course)
      result = described_class.call(student, course)
      expect(result).to be_success
    end
  end
end
