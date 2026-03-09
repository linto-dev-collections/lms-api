class NotificationChannelAdapter
  class << self
    def for(channel)
      case channel.to_sym
      when :in_app
        InAppNotificationDriver
      when :email
        EmailNotifier
      else
        raise ArgumentError, "Unknown notification channel: #{channel}"
      end
    end
  end
end
