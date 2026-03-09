class EnrollmentPolicy < ApplicationPolicy
  def show?
    owner?(record.user_id) ||
      (instructor? && record.course.instructor_id == user.id) ||
      admin?
  end

  def create?
    student?
  end

  def activate?
    owner?(record.user_id)
  end

  def suspend?
    owner?(record.user_id) || admin?
  end

  def resume?
    owner?(record.user_id)
  end

  def progress?
    owner?(record.user_id)
  end
end
