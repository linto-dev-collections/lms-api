require "rails_helper"

RSpec.describe Courses::CreateForm do
  it "is valid with all required attributes" do
    form = described_class.new(
      title: "Ruby入門",
      description: "Rubyの基礎を学ぶコース",
      category: "programming",
      difficulty: "beginner"
    )
    expect(form).to be_valid
  end

  it "normalizes title by stripping whitespace" do
    form = described_class.new(title: "  Ruby入門  ", description: "説明", category: "prog", difficulty: "beginner")
    form.validate
    expect(form.title).to eq("Ruby入門")
  end

  it "normalizes category to lowercase" do
    form = described_class.new(title: "Test", description: "説明", category: " Programming ", difficulty: "beginner")
    form.validate
    expect(form.category).to eq("programming")
  end

  it "is invalid without title" do
    form = described_class.new(description: "説明", category: "prog", difficulty: "beginner")
    expect(form).not_to be_valid
    expect(form.errors[:title]).to be_present
  end

  it "rejects invalid difficulty" do
    form = described_class.new(title: "Test", description: "説明", category: "prog", difficulty: "expert")
    expect(form).not_to be_valid
    expect(form.errors[:difficulty]).to be_present
  end

  it "accepts valid max_enrollment" do
    form = described_class.new(
      title: "Test", description: "説明", category: "prog",
      difficulty: "beginner", max_enrollment: 50
    )
    expect(form).to be_valid
  end

  it "rejects zero max_enrollment" do
    form = described_class.new(
      title: "Test", description: "説明", category: "prog",
      difficulty: "beginner", max_enrollment: 0
    )
    expect(form).not_to be_valid
  end
end
