class UserPasswordMailer < ApplicationMailer

  def email_password(user, password)
    @user = user
    @password = password
    mail(
      to: user.email,
      subject: 'Change me'
    )
  end
end
