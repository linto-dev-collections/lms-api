class ReviewPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    owner?(record.user_id)
  end

  def destroy?
    owner?(record.user_id) || admin?
  end
end
