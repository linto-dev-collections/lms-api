class NotificationPreference::PreferencesType
  include StoreModel::Model

  attribute :in_app, NotificationPreference::ChannelSettings.to_type,
            default: -> { NotificationPreference::ChannelSettings.new }
  attribute :email, NotificationPreference::ChannelSettings.to_type,
            default: -> {
              NotificationPreference::ChannelSettings.new(
                course_approved: false,
                course_rejected: false,
                new_enrollment: false,
                enrollment_created: false,
                certificate_issued: false,
                new_review: false
              )
            }
end
