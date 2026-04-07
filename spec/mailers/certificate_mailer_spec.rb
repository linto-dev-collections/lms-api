require "rails_helper"

RSpec.describe CertificateMailer, type: :mailer do
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published) }
  let(:enrollment) { create(:enrollment, :completed, user: student, course: course) }
  let(:certificate) { create(:certificate, :issued, enrollment: enrollment) }

  describe "#certificate_issued" do
    subject(:mail) do
      described_class.with(certificate: certificate).certificate_issued
    end

    it "sends to the student" do
      expect(mail.to).to eq([ student.email ])
    end

    it "includes the certificate number in body" do
      expect(mail.body.encoded).to include(certificate.certificate_number)
    end
  end
end
