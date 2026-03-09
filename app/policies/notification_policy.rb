class NotificationPolicy < ApplicationPolicy
  def update?
    owner?(record.user_id)
  end
end
