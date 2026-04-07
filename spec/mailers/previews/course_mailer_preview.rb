class CourseMailerPreview < ActionMailer::Preview
  def course_approved
    course = Course.includes(:instructor).first
    CourseMailer.with(course: course).course_approved
  end

  def course_rejected
    course = Course.includes(:instructor).first
    CourseMailer.with(course: course, reason: "内容が不十分です").course_rejected
  end
end
