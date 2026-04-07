class CertificateMailerPreview < ActionMailer::Preview
  def certificate_issued
    certificate = Certificate.includes(enrollment: [ :user, :course ]).first
    CertificateMailer.with(certificate: certificate).certificate_issued
  end
end
