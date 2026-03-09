require "rails_helper"

RSpec.describe EnrollmentPolicy do
  let(:admin) { build(:user, :admin) }
  let(:student) { create(:user, :student) }
  let(:other_student) { create(:user, :student) }
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, instructor: instructor) }
  let(:enrollment) { create(:enrollment, user: student, course: course) }

  describe "#show?" do
    it "allows the enrollment owner" do
      expect(described_class.new(enrollment, user: student)).to be_allowed_to(:show?)
    end

    it "allows the course instructor" do
      expect(described_class.new(enrollment, user: instructor)).to be_allowed_to(:show?)
    end

    it "allows admin" do
      expect(described_class.new(enrollment, user: admin)).to be_allowed_to(:show?)
    end

    it "denies other students" do
      expect(described_class.new(enrollment, user: other_student)).not_to be_allowed_to(:show?)
    end
  end

  describe "#create?" do
    it "allows student" do
      expect(described_class.new(enrollment, user: student)).to be_allowed_to(:create?)
    end

    it "denies instructor" do
      expect(described_class.new(enrollment, user: instructor)).not_to be_allowed_to(:create?)
    end
  end

  describe "#suspend?" do
    it "allows the owner" do
      expect(described_class.new(enrollment, user: student)).to be_allowed_to(:suspend?)
    end

    it "allows admin" do
      expect(described_class.new(enrollment, user: admin)).to be_allowed_to(:suspend?)
    end

    it "denies other students" do
      expect(described_class.new(enrollment, user: other_student)).not_to be_allowed_to(:suspend?)
    end
  end
end
