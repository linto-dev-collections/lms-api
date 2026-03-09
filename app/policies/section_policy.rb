class SectionPolicy < ApplicationPolicy
  def create?
    instructor? && record.course.instructor_id == user.id
  end

  def update?
    instructor? && record.course.instructor_id == user.id
  end

  def destroy?
    instructor? && record.course.instructor_id == user.id
  end
end
