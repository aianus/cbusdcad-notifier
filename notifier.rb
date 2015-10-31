require 'coinbase/wallet'
require 'money/bank/open_exchange_rates_bank'
require 'rest-client'
require 'mailgun'

I18n.enforce_available_locales = false

ACCEPTABLE_COMMISSION = ENV['ACCEPTABLE_COMMISSION'].to_f

module Notifier
  def self.poll
    puts "Polling..."

    moe = Money::Bank::OpenExchangeRatesBank.new
    moe.app_id = ENV['OPEN_EXCHANGE_RATES_APP_ID']
    moe.ttl_in_seconds = 36001
    moe.update_rates
    Money.default_bank = moe

    coinbase = Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
    coinbase_sell_price = coinbase.spot_price
    coinbase_sell_price = Money.from_amount(coinbase_sell_price.amount, coinbase_sell_price.currency)

    coins_response = JSON.parse RestClient.get('https://coins.co.th/api/v1/quote').body
    coins_sell_price = Money.from_amount(coins_response['quote']['bid'], "THB")

    message = <<-END
Price on Coinbase: #{coinbase_sell_price.format}
Price on coins.co.th: #{coins_sell_price.format} (#{coins_sell_price.exchange_to(:USD).format})
END

    puts message

    if coins_sell_price >= coinbase_sell_price * (1 - ACCEPTABLE_COMMISSION)
      mg_client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
      mg_client.send_message ENV['MAILGUN_DOMAIN'], {
        :from    => ENV['NOTIFICATION_SENDER'],
        :to      => ENV['NOTIFICATION_RECIPIENT'],
        :subject => 'Good time to sell BTC for THB',
        :text    => message
      }
    end
  end
end
