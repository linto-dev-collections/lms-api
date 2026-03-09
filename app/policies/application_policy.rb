class ApplicationPolicy < ActionPolicy::Base
  private

  def admin?
    user.admin?
  end

  def instructor?
    user.instructor?
  end

  def student?
    user.student?
  end

  def owner?(record_user_id)
    user.id == record_user_id
  end
end
