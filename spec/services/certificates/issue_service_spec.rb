require "rails_helper"

RSpec.describe Certificates::IssueService do
  let(:enrollment) { create(:enrollment, :completed) }

  describe "#call" do
    it "creates and issues a certificate" do
      result = described_class.call(enrollment)
      expect(result).to be_success
      cert = result.value!
      expect(cert.status).to eq("issued")
      expect(cert.certificate_number).to match(/\ACERT-[A-Z0-9]{8}\z/)
      expect(cert.issued_at).to be_present
    end

    it "fails when enrollment is not completed" do
      active_enrollment = create(:enrollment, :active)
      result = described_class.call(active_enrollment)
      expect(result).to be_failure
      expect(result.failure).to eq(:enrollment_not_completed)
    end
  end
end
