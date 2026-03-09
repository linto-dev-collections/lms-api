require "rails_helper"

RSpec.describe Enrollment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:course) }
    it { is_expected.to have_many(:lesson_progresses).dependent(:destroy) }
    it { is_expected.to have_one(:certificate) }
  end

  describe "validations" do
    subject { build(:enrollment) }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:course_id).with_message("は既にこのコースに受講登録済みです") }
    it { is_expected.to validate_presence_of(:enrolled_at) }
  end

  describe "AASM" do
    let(:course) { create(:course, :published, :with_content) }
    let(:enrollment) { create(:enrollment, course: course) }

    it "starts in pending state" do
      expect(enrollment.aasm.current_state).to eq(:pending)
    end

    it "transitions from pending to active" do
      enrollment.activate!
      expect(enrollment.aasm.current_state).to eq(:active)
    end

    it "requires course to be published for activate" do
      draft_course = create(:course)
      draft_enrollment = create(:enrollment, course: draft_course)
      expect(draft_enrollment.may_activate?).to be false
    end

    it "transitions from active to suspended" do
      enrollment.activate!
      enrollment.suspend!
      expect(enrollment.aasm.current_state).to eq(:suspended)
    end

    it "transitions from suspended to active" do
      enrollment.activate!
      enrollment.suspend!
      enrollment.resume!
      expect(enrollment.aasm.current_state).to eq(:active)
    end

    it "transitions from active to completed when all lessons completed" do
      enrollment.activate!
      course.lessons.each do |lesson|
        create(:lesson_progress, :completed, enrollment: enrollment, lesson: lesson)
      end
      enrollment.complete!
      expect(enrollment.aasm.current_state).to eq(:completed)
    end

    it "does not complete when lessons are not all completed" do
      enrollment.activate!
      expect(enrollment.may_complete?).to be false
    end
  end
end
