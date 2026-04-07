class EnrollmentMailer < ApplicationMailer
  # 受講登録通知 → 講師へ
  def new_enrollment
    @enrollment = params[:enrollment]
    @course = @enrollment.course
    @student = @enrollment.user

    mail(
      to: @course.instructor.email,
      subject: "【LMS】新規受講登録: 「#{@course.title}」"
    )
  end

  # 受講登録完了通知 → 受講者へ
  def enrollment_created
    @enrollment = params[:enrollment]
    @course = @enrollment.course

    mail(
      to: @enrollment.user.email,
      subject: "【LMS】受講登録完了: 「#{@course.title}」"
    )
  end

  # 新規レビュー通知 → 講師へ
  def new_review
    @review = params[:review]
    @course = @review.course

    mail(
      to: @course.instructor.email,
      subject: "【LMS】新しいレビュー: 「#{@course.title}」（評価: #{@review.rating}）"
    )
  end
end
