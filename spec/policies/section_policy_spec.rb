require "rails_helper"

RSpec.describe SectionPolicy do
  let(:instructor) { create(:user, :instructor) }
  let(:other_instructor) { create(:user, :instructor) }
  let(:student) { build(:user, :student) }
  let(:course) { create(:course, instructor: instructor) }
  let(:section) { create(:section, course: course) }

  describe "#create?" do
    it "allows the course instructor" do
      expect(described_class.new(section, user: instructor)).to be_allowed_to(:create?)
    end

    it "denies other instructors" do
      expect(described_class.new(section, user: other_instructor)).not_to be_allowed_to(:create?)
    end

    it "denies students" do
      expect(described_class.new(section, user: student)).not_to be_allowed_to(:create?)
    end
  end

  describe "#update?" do
    it "allows the course instructor" do
      expect(described_class.new(section, user: instructor)).to be_allowed_to(:update?)
    end

    it "denies other instructors" do
      expect(described_class.new(section, user: other_instructor)).not_to be_allowed_to(:update?)
    end
  end

  describe "#destroy?" do
    it "allows the course instructor" do
      expect(described_class.new(section, user: instructor)).to be_allowed_to(:destroy?)
    end

    it "denies other instructors" do
      expect(described_class.new(section, user: other_instructor)).not_to be_allowed_to(:destroy?)
    end
  end
end
