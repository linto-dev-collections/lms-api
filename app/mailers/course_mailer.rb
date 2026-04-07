class CourseMailer < ApplicationMailer
  # コース承認通知 → 講師へ
  def course_approved
    @course = params[:course]

    mail(
      to: @course.instructor.email,
      subject: "【LMS】コース承認: 「#{@course.title}」"
    )
  end

  # コース却下通知 → 講師へ
  def course_rejected
    @course = params[:course]
    @reason = params[:reason]

    mail(
      to: @course.instructor.email,
      subject: "【LMS】コース却下: 「#{@course.title}」"
    )
  end
end
