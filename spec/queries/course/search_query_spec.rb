require "rails_helper"

RSpec.describe Course::SearchQuery do
  let!(:ruby_course) { create(:course, :published, title: "Ruby入門", category: "programming", difficulty: "beginner") }
  let!(:python_course) { create(:course, :published, title: "Python応用", description: "Python上級者向け", category: "programming", difficulty: "advanced") }
  let!(:design_course) { create(:course, :published, title: "UIデザイン", category: "design", difficulty: "intermediate") }

  subject { described_class.new(Course.published) }

  describe "#resolve" do
    it "filters by keyword in title" do
      result = subject.resolve(q: "Ruby")
      expect(result).to include(ruby_course)
      expect(result).not_to include(python_course)
    end

    it "filters by keyword in description" do
      result = subject.resolve(q: "上級者")
      expect(result).to include(python_course)
    end

    it "filters by category" do
      result = subject.resolve(category: "design")
      expect(result).to contain_exactly(design_course)
    end

    it "filters by difficulty" do
      result = subject.resolve(difficulty: "beginner")
      expect(result).to contain_exactly(ruby_course)
    end

    it "sorts by newest" do
      result = subject.resolve(sort: "newest")
      expect(result.first).to eq(Course.published.order(created_at: :desc).first)
    end

    it "applies multiple filters" do
      result = subject.resolve(category: "programming", difficulty: "advanced")
      expect(result).to contain_exactly(python_course)
    end

    it "returns all when no filters applied" do
      result = subject.resolve({})
      expect(result).to include(ruby_course, python_course, design_course)
    end
  end
end
