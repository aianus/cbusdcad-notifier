require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    :address              => ENV.fetch('SMTP_HOST'),
    :port                 => ENV.fetch('SMTP_PORT', 25).to_i,
    :domain               => ENV.fetch('NOTIFICATION_SENDER_DOMAIN'),
    :user_name            => ENV.fetch('SMTP_USERNAME'),
    :password             => ENV.fetch('SMTP_PASSWORD'),
    :authentication       => ENV.fetch('SMTP_AUTHENTICATION_METHOD', 'plain'),
    :enable_starttls_auto => true
  }
end
