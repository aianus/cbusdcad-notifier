require 'coinbase/exchange'
require 'eventmachine'
require 'chronic_duration'
require './lib/mailer.rb'
require './lib/exchange_rates.rb'
require './lib/orderbook.rb'
require './lib/live_orderbook.rb'

I18n.enforce_available_locales = false

class Main
  ACCEPTABLE_COMMISSION = ENV.fetch('ACCEPTABLE_COMMISSION', '0.0').to_f
  NOTIFICATION_INTERVAL = ChronicDuration.parse(ENV.fetch('NOTIFICATION_INTERVAL', '10 minutes'))

  def initialize
    @last_notification_time = Time.now - NOTIFICATION_INTERVAL
    @from_currency = ENV.fetch('@from_currency', 'USD')
    @to_currency = ENV.fetch('@to_currency', 'CAD')
    @from_product_id = "BTC-#{@from_currency}"
    @to_product_id = "BTC-#{@to_currency}"

    @rest_client = Coinbase::Exchange::Client.new(ENV['COINBASE_EXCHANGE_API_KEY'],
                                                  ENV['COINBASE_EXCHANGE_API_SECRET'],
                                                  ENV['COINBASE_EXCHANGE_API_PASSWORD'])

    @from_websocket = Coinbase::Exchange::Websocket.new(product_id: @from_product_id,
                                                        keepalive: true)

    @to_websocket = Coinbase::Exchange::Websocket.new(product_id: @to_product_id,
                                                      keepalive: true)

    @from_book = LiveOrderbook.new(@from_product_id, @rest_client, @from_websocket)
    @to_book = LiveOrderbook.new(@to_product_id, @rest_client, @to_websocket)

    @current_spread = 0
  end

  def evaluate_and_notify
    return unless @to_book.ready? && @from_book.ready?

    to_price = Money.from_amount(@to_book.bids.first[Orderbook::PRICE], @to_currency)
    from_price = Money.from_amount(@from_book.asks.first[Orderbook::PRICE], @from_currency)

    spread = (((to_price / from_price) - 1) * 100)

    if spread == @current_spread
      return
    else
      @current_spread = spread
    end

    message = <<-END
Ask in #{@from_currency}: #{from_price.format}
Bid in #{@to_currency}: #{to_price.format} (#{@from_currency} #{to_price.exchange_to(@from_currency).format})

Spread: #{'%0.2f' % spread}%
END

    puts message

    if Time.now >= (@last_notification_time + NOTIFICATION_INTERVAL) && to_price >= from_price * (1 - ACCEPTABLE_COMMISSION)
      mail         = Mail.new
      mail.from    = ENV.fetch('NOTIFICATION_SENDER', "noreply@#{ENV.fetch('NOTIFICATION_SENDER_DOMAIN')}")
      mail.to      = ENV.fetch('NOTIFICATION_RECIPIENT')
      mail.subject = 'Good time to transfer #'
      mail.text_part do
        content_type 'text/plain; charset=UTF-8'
        body message
      end
      mail.deliver!
      puts "Sending mail at #{Time.now}, notification interval is #{NOTIFICATION_INTERVAL.to_i}"
      @last_notification_time = Time.now
    end
  end

  def start_em
    @from_book.on_change do |_|
      evaluate_and_notify
    end

    @to_book.on_change do |_|
      evaluate_and_notify
    end

    EM.run do
      @from_book.start!
      @to_book.start!
      EM.error_handler { |e|
        p "Websocket Error: #{e.message}"
      }
    end
  end
end

Main.new.start_em