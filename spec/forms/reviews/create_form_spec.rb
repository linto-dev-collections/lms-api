require "rails_helper"

RSpec.describe Reviews::CreateForm do
  it "is valid with valid rating" do
    form = described_class.new(rating: 5)
    expect(form).to be_valid
  end

  it "is invalid with rating out of range" do
    form = described_class.new(rating: 6)
    expect(form).not_to be_valid
  end

  it "is invalid without rating" do
    form = described_class.new(comment: "test")
    expect(form).not_to be_valid
  end
end
