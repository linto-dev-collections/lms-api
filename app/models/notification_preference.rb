class NotificationPreference < ApplicationRecord
  # Associations
  belongs_to :user

  # StoreModel
  attribute :preferences, NotificationPreference::PreferencesType.to_type,
            default: -> { NotificationPreference::PreferencesType.new }

  validates :preferences, store_model: true

  # Validations
  validates :user_id, uniqueness: true

  def enabled?(channel, notification_type)
    channel_settings = preferences.public_send(channel)
    return false unless channel_settings

    channel_settings.public_send(notification_type)
  rescue NoMethodError
    false
  end
end
