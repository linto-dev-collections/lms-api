require "rails_helper"

RSpec.describe CertificateNotifier do
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published) }
  let(:enrollment) { create(:enrollment, :completed, user: student, course: course) }
  let(:certificate) { create(:certificate, :issued, enrollment: enrollment) }

  describe "#certificate_issued" do
    it "sends a notification to the student" do
      expect {
        described_class.with(certificate: certificate).certificate_issued.notify_now
      }.to have_sent_notification

      delivery = AbstractNotifier::Testing::Driver.deliveries.last
      expect(delivery[:to]).to eq(student)
      expect(delivery[:notification_type]).to eq("certificate_issued")
      expect(delivery[:params][:certificate_number]).to eq(certificate.certificate_number)
    end
  end
end
