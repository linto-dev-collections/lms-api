class ApplicationMailer < ActionMailer::Base
  default from: -> { MailerConfig.instance.from_address }
  layout false
end
