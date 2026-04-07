class ApplicationDelivery < ActiveDelivery::Base
  self.abstract_class = true

  register_line :notifier, ActiveDelivery::Lines::Notifier

  # Email 通知の有効/無効を NotificationPreference で制御
  before_notify :check_email_preference, on: :mailer

  private

  def check_email_preference
    user = recipient
    return false unless user

    preference = user.notification_preference
    return false unless preference

    !!preference.enabled?(:email, notification_name.to_s)
  end

  # サブクラスでオーバーライドする
  def recipient
    nil
  end
end
