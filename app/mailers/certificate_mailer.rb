class CertificateMailer < ApplicationMailer
  # 修了証発行通知 → 受講者へ
  def certificate_issued
    @certificate = params[:certificate]
    @enrollment = @certificate.enrollment
    @course = @enrollment.course

    mail(
      to: @enrollment.user.email,
      subject: "【LMS】修了証発行: 「#{@course.title}」"
    )
  end
end
