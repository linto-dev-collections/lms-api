class CertificateNotifier < AbstractNotifier::Base
  self.driver = InAppNotificationDriver.new

  # 修了証発行通知 → 受講者へ
  def certificate_issued
    certificate = params[:certificate]
    enrollment = certificate.enrollment

    notification(
      body: "「#{enrollment.course.title}」の修了証が発行されました",
      to: enrollment.user,
      notification_type: "certificate_issued",
      params: {
        course_id: enrollment.course.id,
        course_title: enrollment.course.title,
        certificate_number: certificate.certificate_number
      }
    )
  end
end
