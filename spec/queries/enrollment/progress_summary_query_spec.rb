require "rails_helper"

RSpec.describe Enrollment::ProgressSummaryQuery do
  let(:course) { create(:course, :published) }
  let(:section) { create(:section, course: course) }
  let!(:lesson1) { create(:lesson, section: section) }
  let!(:lesson2) { create(:lesson, section: section) }
  let!(:lesson3) { create(:lesson, section: section) }
  let(:enrollment) { create(:enrollment, :active, course: course) }

  describe "#resolve" do
    it "returns correct progress summary" do
      create(:lesson_progress, :completed, enrollment: enrollment, lesson: lesson1)
      create(:lesson_progress, :in_progress, enrollment: enrollment, lesson: lesson2)

      summary = described_class.new(enrollment).resolve

      expect(summary[:total_lessons]).to eq(3)
      expect(summary[:completed_lessons]).to eq(1)
      expect(summary[:in_progress_lessons]).to eq(1)
      expect(summary[:not_started_lessons]).to eq(1)
      expect(summary[:percentage]).to eq(33.3)
    end

    it "returns 0 percentage when no lessons" do
      empty_course = create(:course, :published)
      empty_enrollment = create(:enrollment, :active, course: empty_course)

      summary = described_class.new(empty_enrollment).resolve
      expect(summary[:percentage]).to eq(0.0)
    end
  end
end
