class EnrollmentNotifier < AbstractNotifier::Base
  self.driver = InAppNotificationDriver.new

  # 受講登録通知 → 講師へ
  def new_enrollment
    enrollment = params[:enrollment]
    course = enrollment.course

    notification(
      body: "#{enrollment.user.name}さんが「#{course.title}」に受講登録しました",
      to: course.instructor,
      notification_type: "new_enrollment",
      params: {
        course_id: course.id,
        course_title: course.title,
        student_name: enrollment.user.name
      }
    )
  end

  # 受講登録完了通知 → 受講者へ
  def enrollment_created
    enrollment = params[:enrollment]

    notification(
      body: "「#{enrollment.course.title}」への受講登録が完了しました",
      to: enrollment.user,
      notification_type: "enrollment_created",
      params: {
        course_id: enrollment.course.id,
        course_title: enrollment.course.title
      }
    )
  end

  # 新規レビュー通知 → 講師へ
  def new_review
    review = params[:review]
    course = review.course

    notification(
      body: "「#{course.title}」に新しいレビューが投稿されました（評価: #{review.rating}）",
      to: course.instructor,
      notification_type: "new_review",
      params: {
        course_id: course.id,
        course_title: course.title,
        rating: review.rating
      }
    )
  end
end
