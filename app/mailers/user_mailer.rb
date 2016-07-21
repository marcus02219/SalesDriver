class UserMailer < ApplicationMailer
  def send_created_notification_to_seller email, pswd
    @pswd = pswd
    mail(to: email, subject: 'Welcome')
  end
end
