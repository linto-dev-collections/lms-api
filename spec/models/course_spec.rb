require "rails_helper"

RSpec.describe Course, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:instructor).class_name("User") }
    it { is_expected.to have_many(:sections).dependent(:destroy) }
    it { is_expected.to have_many(:lessons).through(:sections) }
    it { is_expected.to have_many(:enrollments) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:difficulty) }
    it { is_expected.to allow_value(nil).for(:max_enrollment) }
    it { is_expected.to validate_numericality_of(:max_enrollment).is_greater_than(0).allow_nil }
  end

  describe "AASM" do
    let(:course) { create(:course, :with_content) }

    it "starts in draft state" do
      expect(course.aasm.current_state).to eq(:draft)
    end

    it "transitions from draft to under_review" do
      course.submit_for_review!
      expect(course.aasm.current_state).to eq(:under_review)
    end

    it "requires content for submit_for_review" do
      empty_course = create(:course)
      expect(empty_course.may_submit_for_review?).to be false
    end

    it "transitions from under_review to published" do
      course.submit_for_review!
      course.approve!
      expect(course.aasm.current_state).to eq(:published)
    end

    it "transitions from under_review to rejected" do
      course.submit_for_review!
      course.reject!
      expect(course.aasm.current_state).to eq(:rejected)
    end

    it "transitions from rejected to draft" do
      course.submit_for_review!
      course.reject!
      course.revise!
      expect(course.aasm.current_state).to eq(:draft)
    end

    it "transitions from published to draft" do
      course.submit_for_review!
      course.approve!
      course.unpublish!
      expect(course.aasm.current_state).to eq(:draft)
    end
  end
end
