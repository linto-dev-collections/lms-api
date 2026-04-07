class EmailVerificationMailer < ApplicationMailer
  def verify(user, token)
    @user = user
    @token = token

    mail(
      to: @user.email,
      subject: "【LMS】メールアドレスの確認"
    )
  end
end
