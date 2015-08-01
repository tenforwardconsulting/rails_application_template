class UserPasswordMailerGenerator < Rails::Generators::Base
  desc "This generator creates a mailer to send passwords to users"

  def create_user_password_mailer
    copy_file 'user_password_mailer.rb', 'app/mailers/user_password_mailer.rb'
    copy_file 'email_password.html.haml', 'app/views/user_password_mailer/email_password.html.haml'
  end
end
