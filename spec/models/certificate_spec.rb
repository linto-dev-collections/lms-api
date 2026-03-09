require "rails_helper"

RSpec.describe Certificate, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:enrollment) }
    it { is_expected.to have_one(:user).through(:enrollment) }
    it { is_expected.to have_one(:course).through(:enrollment) }
  end

  describe "validations" do
    subject { build(:certificate) }

    it { is_expected.to validate_uniqueness_of(:enrollment_id) }
    it { is_expected.to validate_presence_of(:certificate_number) }
    it { is_expected.to validate_uniqueness_of(:certificate_number) }
  end

  describe "AASM" do
    let(:certificate) { create(:certificate) }

    it "starts in pending state" do
      expect(certificate.aasm.current_state).to eq(:pending)
    end

    it "transitions from pending to issued" do
      certificate.issue!
      expect(certificate.aasm.current_state).to eq(:issued)
    end

    it "transitions from issued to revoked" do
      certificate.issue!
      certificate.revoke!
      expect(certificate.aasm.current_state).to eq(:revoked)
    end
  end
end
