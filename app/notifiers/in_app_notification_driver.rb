class InAppNotificationDriver
  def call(payload)
    recipient = payload[:to]
    return if recipient.nil?

    # 通知プリファレンスチェック
    preference = recipient.notification_preference
    if preference && !preference.enabled?(:in_app, payload[:notification_type])
      return
    end

    Notification.create!(
      user: recipient,
      notification_type: payload[:notification_type],
      params: payload[:params] || {}
    )
  end
end
