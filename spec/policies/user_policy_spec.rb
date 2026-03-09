require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin) { build(:user, :admin) }
  let(:instructor) { build(:user, :instructor) }
  let(:student) { build(:user, :student) }

  describe "#index?" do
    it "allows admin" do
      expect(described_class.new(User, user: admin)).to be_allowed_to(:index?)
    end

    it "denies instructor" do
      expect(described_class.new(User, user: instructor)).not_to be_allowed_to(:index?)
    end

    it "denies student" do
      expect(described_class.new(User, user: student)).not_to be_allowed_to(:index?)
    end
  end

  describe "#show?" do
    it "allows admin" do
      expect(described_class.new(User, user: admin)).to be_allowed_to(:show?)
    end

    it "denies student" do
      expect(described_class.new(User, user: student)).not_to be_allowed_to(:show?)
    end
  end
end
