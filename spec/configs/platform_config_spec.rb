# spec/configs/platform_config_spec.rb
require "rails_helper"

RSpec.describe PlatformConfig do
  subject(:config) { described_class.new }

  it "has max_enrollment_per_course" do
    expect(config.max_enrollment_per_course).to eq(10)
  end

  it "has review_min_rating" do
    expect(config.review_min_rating).to eq(1)
  end

  it "has review_max_rating" do
    expect(config.review_max_rating).to eq(5)
  end

  it "has pagination_default_per_page" do
    expect(config.pagination_default_per_page).to eq(5)
  end

  it "has pagination_max_per_page" do
    expect(config.pagination_max_per_page).to eq(20)
  end
end
