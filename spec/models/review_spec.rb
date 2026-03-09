require "rails_helper"

RSpec.describe Review, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:course) }
  end

  describe "validations" do
    subject { build(:review) }

    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:course_id).with_message("は既にこのコースにレビュー投稿済みです") }
  end
end
