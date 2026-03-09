class CoursePolicy < ApplicationPolicy
  def show?
    record.published? || admin? || (instructor? && record.instructor_id == user.id)
  end

  def create?
    instructor?
  end

  def update?
    admin? || (instructor? && record.instructor_id == user.id)
  end

  def destroy?
    admin? || (instructor? && record.instructor_id == user.id && record.draft?)
  end

  def submit_for_review?
    instructor? && record.instructor_id == user.id
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end

  def unpublish?
    admin? || (instructor? && record.instructor_id == user.id)
  end

  def archive?
    admin? || (instructor? && record.instructor_id == user.id)
  end

  def unarchive?
    admin? || (instructor? && record.instructor_id == user.id)
  end

  relation_scope do |relation|
    if admin?
      relation.all
    elsif instructor?
      relation.where(instructor_id: user.id)
    else
      relation.where(status: :published)
    end
  end
end
