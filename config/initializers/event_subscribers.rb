# 受講登録イベント
ActiveSupport::Notifications.subscribe("created.enrollment") do |*, payload|
  enrollment = payload[:enrollment]
  EnrollmentDelivery.with(enrollment: enrollment).notify(:new_enrollment)
  EnrollmentDelivery.with(enrollment: enrollment).notify(:enrollment_created)
end

# 受講修了イベント
ActiveSupport::Notifications.subscribe("completed.enrollment") do |*, payload|
  # 修了通知はここでは不要（certificate_issued で通知する）
end

# 修了証発行イベント
ActiveSupport::Notifications.subscribe("issued.certificate") do |*, payload|
  certificate = payload[:certificate]
  CertificateDelivery.with(certificate: certificate).notify(:certificate_issued)
end

# コース承認イベント
ActiveSupport::Notifications.subscribe("approved.course") do |*, payload|
  course = payload[:course]
  CourseDelivery.with(course: course).notify(:course_approved)
end

# コース却下イベント
ActiveSupport::Notifications.subscribe("rejected.course") do |*, payload|
  course = payload[:course]
  reason = payload[:reason]
  CourseDelivery.with(course: course, reason: reason).notify(:course_rejected)
end

# レビュー投稿イベント
ActiveSupport::Notifications.subscribe("created.review") do |*, payload|
  review = payload[:review]
  # 講師自身のレビューは通知しない（通常発生しないが念のため）
  unless review.user_id == review.course.instructor_id
    EnrollmentDelivery.with(review: review).notify(:new_review)
  end
end
