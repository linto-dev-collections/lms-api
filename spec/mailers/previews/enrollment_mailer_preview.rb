class EnrollmentMailerPreview < ActionMailer::Preview
  def new_enrollment
    enrollment = Enrollment.includes(:user, course: :instructor).first
    EnrollmentMailer.with(enrollment: enrollment).new_enrollment
  end

  def enrollment_created
    enrollment = Enrollment.includes(:user, :course).first
    EnrollmentMailer.with(enrollment: enrollment).enrollment_created
  end

  def new_review
    review = Review.includes(:user, course: :instructor).first
    EnrollmentMailer.with(review: review).new_review
  end
end
