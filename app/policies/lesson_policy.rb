class LessonPolicy < ApplicationPolicy
  def show?
    admin? ||
      (instructor? && record.course.instructor_id == user.id) ||
      user.enrollments.exists?(course_id: record.section.course_id, status: %w[active completed])
  end
end
