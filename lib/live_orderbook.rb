require './lib/orderbook.rb'

class LiveOrderbook
  attr_accessor :sequence

  def initialize(product_id, rest_client = nil, websocket = nil)
    @product_id = product_id
    @websocket = websocket
    @rest_client = rest_client

    @websocket.message do |msg|
      process_message(msg)
    end

    @queue = Queue.new

    @on_change_cb = lambda { |msg| nil }
  end

  def start!
    @websocket.start!
    refresh!
  end

  def on_change(&block)
    @on_change_cb = block
  end

  def process_message(msg)
    if !ready?
      @queue << msg
    elsif msg['sequence'] > @sequence + 1
      refresh!
    elsif msg['sequence'] == @sequence + 1
      case msg['type']
      when "open"
        @orderbook.open(msg)
      when "done"
        @orderbook.done(msg)
      when "change"
        @orderbook.change(msg)
      end

      @sequence = msg['sequence'].to_i
      @on_change_cb.call(msg)
    end
  end

  def refresh!
    puts "Refreshing orderbook from snapshot!"

    @orderbook = nil
    @rest_client.orderbook(product_id: @product_id, level: 3) do |resp|
      @orderbook = Orderbook.new(resp)
      @sequence = resp['sequence'].to_i

      while !@queue.empty?
        process_message(@queue.pop)
      end
    end
  end

  def ready?
    !@orderbook.nil?
  end

  def bids
    @orderbook.bids
  end

  def asks
    @orderbook.asks
  end
end
