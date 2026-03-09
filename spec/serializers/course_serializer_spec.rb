require "rails_helper"

RSpec.describe CourseSerializer do
  let(:course) { create(:course, :published, :with_content) }

  it "serializes course attributes" do
    result = described_class.new(course).serialize
    parsed = JSON.parse(result)["course"]

    expect(parsed["id"]).to eq(course.id)
    expect(parsed["title"]).to eq(course.title)
    expect(parsed["status"]).to eq("published")
    expect(parsed["instructor"]).to include("id", "name")
    expect(parsed).to have_key("enrollment_count")
    expect(parsed).to have_key("average_rating")
  end
end
