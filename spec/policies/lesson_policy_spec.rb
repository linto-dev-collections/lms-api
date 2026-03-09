require "rails_helper"

RSpec.describe LessonPolicy do
  let(:admin) { build(:user, :admin) }
  let(:instructor) { create(:user, :instructor) }
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published, instructor: instructor) }
  let(:section) { create(:section, course: course) }
  let(:lesson) { create(:lesson, section: section) }

  describe "#show?" do
    it "allows admin" do
      expect(described_class.new(lesson, user: admin)).to be_allowed_to(:show?)
    end

    it "allows the course instructor" do
      expect(described_class.new(lesson, user: instructor)).to be_allowed_to(:show?)
    end

    it "allows enrolled student" do
      create(:enrollment, :active, user: student, course: course)
      expect(described_class.new(lesson, user: student)).to be_allowed_to(:show?)
    end

    it "denies non-enrolled student" do
      expect(described_class.new(lesson, user: student)).not_to be_allowed_to(:show?)
    end
  end
end
