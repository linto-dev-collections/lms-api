require "rails_helper"

RSpec.describe Enrollment::FilterQuery do
  let(:course1) { create(:course, :published) }
  let(:course2) { create(:course, :published) }

  before do
    create(:enrollment, course: course1, status: "pending")
    create(:enrollment, :active, course: course1)
    create(:enrollment, course: course2, status: "pending")
  end

  describe "#resolve" do
    it "filters by course_id" do
      result = described_class.new.resolve(course_id: course1.id)
      expect(result.count).to eq(2)
    end

    it "filters by status" do
      result = described_class.new.resolve(status: "active")
      expect(result.count).to eq(1)
    end

    it "combines filters" do
      result = described_class.new.resolve(course_id: course1.id, status: "pending")
      expect(result.count).to eq(1)
    end

    it "returns all when no filters" do
      result = described_class.new.resolve({})
      expect(result.count).to eq(3)
    end
  end
end
