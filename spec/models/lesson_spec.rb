require "rails_helper"

RSpec.describe Lesson, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:section) }
    it { is_expected.to have_one(:course).through(:section) }
    it { is_expected.to have_many(:lesson_progresses).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_presence_of(:content_type) }
    it { is_expected.to validate_presence_of(:duration_minutes) }
    it { is_expected.to validate_numericality_of(:duration_minutes).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:content_type).backed_by_column_of_type(:string).with_values(text: "text", video: "video", quiz: "quiz") }
  end
end
