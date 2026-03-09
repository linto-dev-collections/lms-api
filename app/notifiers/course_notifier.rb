class CourseNotifier < AbstractNotifier::Base
  self.driver = InAppNotificationDriver.new

  # コース承認通知 → 講師へ
  def course_approved
    course = params[:course]

    notification(
      body: "「#{course.title}」が承認されました",
      to: course.instructor,
      notification_type: "course_approved",
      params: {
        course_id: course.id,
        course_title: course.title
      }
    )
  end

  # コース却下通知 → 講師へ
  def course_rejected
    course = params[:course]

    notification(
      body: "「#{course.title}」が却下されました",
      to: course.instructor,
      notification_type: "course_rejected",
      params: {
        course_id: course.id,
        course_title: course.title,
        reason: params[:reason]
      }
    )
  end
end
