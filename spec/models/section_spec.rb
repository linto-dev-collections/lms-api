require "rails_helper"

RSpec.describe Section, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to have_many(:lessons).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position).is_greater_than_or_equal_to(0) }
  end
end
