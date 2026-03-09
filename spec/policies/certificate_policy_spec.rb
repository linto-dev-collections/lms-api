require "rails_helper"

RSpec.describe CertificatePolicy do
  let(:user) { build(:user) }

  describe "#index?" do
    it "allows any authenticated user" do
      expect(described_class.new(Certificate, user: user)).to be_allowed_to(:index?)
    end
  end
end
