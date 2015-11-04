require 'coinbase'
require 'rest-client'
require './lib/mailer.rb'
require './lib/exchange_rates.rb'

I18n.enforce_available_locales = false

ACCEPTABLE_COMMISSION = ENV.fetch('ACCEPTABLE_COMMISSION', '0.0').to_f

module Notifier
  def self.poll
    puts "Polling..."

    coinbase = Coinbase::Client.new
    spot_price = coinbase.spot_price

    coins_response = JSON.parse RestClient.get('https://coins.co.th/api/v1/quote').body
    coins_sell_price = Money.from_amount(coins_response['quote']['bid'], "THB")

    message = <<-END
Price on Coinbase: #{spot_price.format}
Price on coins.co.th: #{coins_sell_price.format} (#{coins_sell_price.exchange_to(:USD).format})
END

    puts message

    if coins_sell_price >= spot_price * (1 - ACCEPTABLE_COMMISSION)
      mail         = Mail.new
      mail.from = ENV.fetch('NOTIFICATION_SENDER', "noreply@#{ENV.fetch('NOTIFICATION_SENDER_DOMAIN')}")
      mail.to = ENV.fetch('NOTIFICATION_RECIPIENT')
      mail.subject = 'Good time to sell BTC for THB'
      mail.text_part do
        content_type 'text/plain; charset=UTF-8'
        body message
      end
      mail.deliver!
    end
  end
end
