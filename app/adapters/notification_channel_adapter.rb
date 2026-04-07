class NotificationChannelAdapter
  class << self
    def for(channel)
      case channel.to_sym
      when :in_app
        InAppNotificationDriver
      when :email
        # Active Delivery の mailer line 経由で配信するため、
        # アダプターからの直接参照は不要。
        raise NotImplementedError, "Email delivery is handled by Active Delivery mailer line"
      else
        raise ArgumentError, "Unknown notification channel: #{channel}"
      end
    end
  end
end
