require "rails_helper"

RSpec.describe ReviewPolicy do
  let(:admin) { build(:user, :admin) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:review) { create(:review, user: user) }

  describe "#create?" do
    it "allows any user" do
      expect(described_class.new(review, user: user)).to be_allowed_to(:create?)
    end
  end

  describe "#update?" do
    it "allows the review owner" do
      expect(described_class.new(review, user: user)).to be_allowed_to(:update?)
    end

    it "denies other users" do
      expect(described_class.new(review, user: other_user)).not_to be_allowed_to(:update?)
    end
  end

  describe "#destroy?" do
    it "allows the review owner" do
      expect(described_class.new(review, user: user)).to be_allowed_to(:destroy?)
    end

    it "allows admin" do
      expect(described_class.new(review, user: admin)).to be_allowed_to(:destroy?)
    end

    it "denies other users" do
      expect(described_class.new(review, user: other_user)).not_to be_allowed_to(:destroy?)
    end
  end
end
