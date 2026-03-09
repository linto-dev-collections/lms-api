class NotificationSerializer
  include Alba::Resource

  root_key :notification

  attributes :id, :notification_type, :params, :read_at, :created_at

  attribute :read do |notification|
    notification.read?
  end
end
