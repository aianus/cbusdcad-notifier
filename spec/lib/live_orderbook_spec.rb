require 'spec_helper'
require 'live_orderbook'
require 'coinbase/exchange'

vcr_options = { :cassette_name => "btc-cad-orderbook", :record => :none }
describe LiveOrderbook, vcr: vcr_options do
  let(:rest_client) do
    Coinbase::Exchange::AsyncClient.new('api_key',
                                        'api_secret',
                                        'api_passphrase')
  end
  let(:websocket) do
    Coinbase::Exchange::Websocket.new(product_id: 'BTC-CAD',
                                      keepalive: true)
  end
  let(:orderbook) { LiveOrderbook.new('BTC-CAD', rest_client, websocket) }


  it "queues up websocket messages from before the orderbook is loaded" do
    @message_queue = Queue.new


    # Outdated open message for the best bid in the snapshot
    @message_queue << {
        "type" => "open",
        "product_id" => "BTC-CAD",
        "sequence" => 101711923,
        "order_id" => "8af6743a-bd07-43fd-a8ab-c4bc9bcf2524",
        "price" => "627.53",
        "remaining_size" => "0.01022184",
        "side" => "buy"
    }

    # Outdated open message for the best ask in the snapshot
    @message_queue << {
        "type" => "open",
        "product_id" => "BTC-CAD",
        "sequence" => 101711924,
        "order_id" => "ae3965bd-b34f-4dd2-8c91-2ca82a8c6cdf",
        "price" => "630.39",
        "remaining_size" => "2.0218",
        "side" => "sell"
    }

    # New open message for a new best ask
    @message_queue << {
        "type" => "open",
        "product_id" => "BTC-CAD",
        "sequence" => 101711925,
        "order_id" => "d50ec984-77a8-460a-b958-66f114b0de9b",
        "price" => '630.37',
        "remaining_size" => "1.26",
        "side" => "sell"
    }

    # @orderbook.start! (simulated)
    while !@message_queue.empty?
      orderbook.process_message(@message_queue.pop)
    end

    orderbook.refresh!

    expect(orderbook.asks.first[Orderbook::PRICE]).to eq(BigDecimal.new("630.37"))
    expect(orderbook.asks.first[Orderbook::SIZE]).to eq(BigDecimal.new("1.26"))
    expect(orderbook.asks.first[Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")

    expect(orderbook.asks[1][Orderbook::PRICE]).to eq(BigDecimal.new("630.39"))
    expect(orderbook.asks[1][Orderbook::SIZE]).to eq(BigDecimal.new("2.0218"))
    expect(orderbook.asks[1][Orderbook::ORDER_ID]).to eq("ae3965bd-b34f-4dd2-8c91-2ca82a8c6cdf")

    expect(orderbook.sequence).to eq(101711925)
  end
end
