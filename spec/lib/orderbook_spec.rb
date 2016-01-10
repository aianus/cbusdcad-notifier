require 'spec_helper'
require 'orderbook'
require 'coinbase/exchange'



vcr_options = { :cassette_name => "btc-cad-orderbook", :record => :none }
describe Orderbook, vcr: vcr_options do
  let(:initial_state) do
    client = Coinbase::Exchange::Client.new('api_key',
                                            'api_secret',
                                            'api_pass')

    client.orderbook(product_id: 'BTC-CAD', level: 3)
  end

  let(:orderbook) do
    Orderbook.new(initial_state)
  end

  it "successfully instantiates an orderbook with initial state" do
    expect(orderbook).not_to be_nil

    expect(orderbook.bids.first[Orderbook::PRICE]).to eq(BigDecimal.new("627.53"))
    expect(orderbook.bids.first[Orderbook::SIZE]).to eq(BigDecimal.new("0.01022184"))
    expect(orderbook.bids.first[Orderbook::ORDER_ID]).to eq("8af6743a-bd07-43fd-a8ab-c4bc9bcf2524")

    expect(orderbook.bids[1][Orderbook::PRICE]).to eq(BigDecimal.new("627.43"))
    expect(orderbook.bids[1][Orderbook::SIZE]).to eq(BigDecimal.new("0.16"))
    expect(orderbook.bids[1][Orderbook::ORDER_ID]).to eq("ca1a922b-7f25-45dd-bc35-b43c10d34077")

    expect(orderbook.asks.first[Orderbook::PRICE]).to eq(BigDecimal.new("630.39"))
    expect(orderbook.asks.first[Orderbook::SIZE]).to eq(BigDecimal.new("2.0218"))
    expect(orderbook.asks.first[Orderbook::ORDER_ID]).to eq("ae3965bd-b34f-4dd2-8c91-2ca82a8c6cdf")

    expect(orderbook.asks[1][Orderbook::PRICE]).to eq(BigDecimal.new("630.43"))
    expect(orderbook.asks[1][Orderbook::SIZE]).to eq(BigDecimal.new("2.4912"))
    expect(orderbook.asks[1][Orderbook::ORDER_ID]).to eq("b1b5fdf6-3f1c-4867-8dd4-8822617fda64")
  end

  context 'open' do
    let(:message) do
      {
        "type" => "open",
        "product_id" => "BTC-CAD",
        "sequence" => 101711925,
        "order_id" => "d50ec984-77a8-460a-b958-66f114b0de9b",
        "price" => "200.2",
        "remaining_size" => "1.00",
        "side" => "sell"
      }
    end

    context 'bids' do
      it "correctly inserts a new best bid" do
        message['side'] = 'buy'
        message['price'] = '627.54'
        message['remaining_size'] = '1.23'

        orderbook.open(message)

        expect(orderbook.bids.first[Orderbook::PRICE]).to eq(BigDecimal.new("627.54"))
        expect(orderbook.bids.first[Orderbook::SIZE]).to eq(BigDecimal.new("1.23"))
        expect(orderbook.bids.first[Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")

        expect(orderbook.bids[1][Orderbook::PRICE]).to eq(BigDecimal.new("627.53"))
        expect(orderbook.bids[1][Orderbook::SIZE]).to eq(BigDecimal.new("0.01022184"))
        expect(orderbook.bids[1][Orderbook::ORDER_ID]).to eq("8af6743a-bd07-43fd-a8ab-c4bc9bcf2524")
      end

      it "correctly inserts a new bid" do
        message['side'] = 'buy'
        message['price'] = '627.50'
        message['remaining_size'] = '1.24'

        orderbook.open(message)

        expect(orderbook.bids.first[Orderbook::PRICE]).to eq(BigDecimal.new("627.53"))
        expect(orderbook.bids.first[Orderbook::SIZE]).to eq(BigDecimal.new("0.01022184"))
        expect(orderbook.bids.first[Orderbook::ORDER_ID]).to eq("8af6743a-bd07-43fd-a8ab-c4bc9bcf2524")

        expect(orderbook.bids[1][Orderbook::PRICE]).to eq(BigDecimal.new("627.50"))
        expect(orderbook.bids[1][Orderbook::SIZE]).to eq(BigDecimal.new("1.24"))
        expect(orderbook.bids[1][Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")
      end

      it "correctly inserts a new worst bid" do
        message['side'] = 'buy'
        message['price'] = '400.50'
        message['remaining_size'] = '1.25'

        orderbook.open(message)

        expect(orderbook.bids.last[Orderbook::PRICE]).to eq(BigDecimal.new("400.50"))
        expect(orderbook.bids.last[Orderbook::SIZE]).to eq(BigDecimal.new("1.25"))
        expect(orderbook.bids.last[Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")
      end
    end

    context 'asks' do
      it "correctly inserts a new best ask" do
        message['price'] = '630.37'
        message['remaining_size'] = '1.26'

        orderbook.open(message)

        expect(orderbook.asks.first[Orderbook::PRICE]).to eq(BigDecimal.new("630.37"))
        expect(orderbook.asks.first[Orderbook::SIZE]).to eq(BigDecimal.new("1.26"))
        expect(orderbook.asks.first[Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")

        expect(orderbook.asks[1][Orderbook::PRICE]).to eq(BigDecimal.new("630.39"))
        expect(orderbook.asks[1][Orderbook::SIZE]).to eq(BigDecimal.new("2.0218"))
        expect(orderbook.asks[1][Orderbook::ORDER_ID]).to eq("ae3965bd-b34f-4dd2-8c91-2ca82a8c6cdf")
      end

      it "correctly inserts a new ask" do
        message['price'] = '630.42'
        message['remaining_size'] = '1.27'

        orderbook.open(message)

        expect(orderbook.asks.first[Orderbook::PRICE]).to eq(BigDecimal.new("630.39"))
        expect(orderbook.asks.first[Orderbook::SIZE]).to eq(BigDecimal.new("2.0218"))
        expect(orderbook.asks.first[Orderbook::ORDER_ID]).to eq("ae3965bd-b34f-4dd2-8c91-2ca82a8c6cdf")

        expect(orderbook.asks[1][Orderbook::PRICE]).to eq(BigDecimal.new("630.42"))
        expect(orderbook.asks[1][Orderbook::SIZE]).to eq(BigDecimal.new("1.27"))
        expect(orderbook.asks[1][Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")
      end

      it "correctly inserts a new worst ask" do
        message['price'] = '766'
        message['remaining_size'] = '1.28'

        orderbook.open(message)

        expect(orderbook.asks.last[Orderbook::PRICE]).to eq(BigDecimal.new("766"))
        expect(orderbook.asks.last[Orderbook::SIZE]).to eq(BigDecimal.new("1.28"))
        expect(orderbook.asks.last[Orderbook::ORDER_ID]).to eq("d50ec984-77a8-460a-b958-66f114b0de9b")
      end
    end
  end

  context 'done' do
    it "correctly closes an ask" do
      message = {
        "side" => "sell",
        "order_id" => "ae3965bd-b34f-4dd2-8c91-2ca82a8c6cdf"
      }

      expect{orderbook.done(message)}.to change{orderbook.asks.length}.by(-1)

      expect(orderbook.asks.first[Orderbook::PRICE]).to eq(BigDecimal.new("630.43"))
      expect(orderbook.asks.first[Orderbook::SIZE]).to eq(BigDecimal.new("2.4912"))
      expect(orderbook.asks.first[Orderbook::ORDER_ID]).to eq("b1b5fdf6-3f1c-4867-8dd4-8822617fda64")
    end

    it "correctly closes a bid" do
      message = {
        "side" => "buy",
        "order_id" => "8af6743a-bd07-43fd-a8ab-c4bc9bcf2524"
      }

      expect{orderbook.done(message)}.to change{orderbook.bids.length}.by(-1)

      expect(orderbook.bids.first[Orderbook::PRICE]).to eq(BigDecimal.new("627.43"))
      expect(orderbook.bids.first[Orderbook::SIZE]).to eq(BigDecimal.new("0.16"))
      expect(orderbook.bids.first[Orderbook::ORDER_ID]).to eq("ca1a922b-7f25-45dd-bc35-b43c10d34077")
    end
  end

  context 'change' do
    it 'correctly changes a bid' do
      message = {
        "order_id" => "8af6743a-bd07-43fd-a8ab-c4bc9bcf2524",
        "new_size" => "0.00522184",
        "old_size" => "0.01022184",
        "price" => "627.53",
        "side" => "buy"
      }

      orderbook.change(message)

      expect(orderbook.bids.first[Orderbook::PRICE]).to eq(BigDecimal.new("627.53"))
      expect(orderbook.bids.first[Orderbook::SIZE]).to eq(BigDecimal.new("0.00522184"))
      expect(orderbook.bids.first[Orderbook::ORDER_ID]).to eq("8af6743a-bd07-43fd-a8ab-c4bc9bcf2524")
    end

    it 'raises an exception if the old size doesnt match' do
      message = {
        "order_id" => "8af6743a-bd07-43fd-a8ab-c4bc9bcf2524",
        "new_size" => "0.00522184",
        "old_size" => "0.01022185",
        "price" => "627.53",
        "side" => "buy"
      }

      expect{orderbook.change(message)}.to raise_error("Change message received but old_size does not match current size")
    end

    it 'correctly changes an ask' do
      message = {
        "order_id" => "b1b5fdf6-3f1c-4867-8dd4-8822617fda64",
        "new_size" => "1.4912",
        "old_size" => "2.4912",
        "price" => "630.43",
        "side" => "sell"
      }

      orderbook.change(message)

      expect(orderbook.asks[1][Orderbook::PRICE]).to eq(BigDecimal.new("630.43"))
      expect(orderbook.asks[1][Orderbook::SIZE]).to eq(BigDecimal.new("1.4912"))
      expect(orderbook.asks[1][Orderbook::ORDER_ID]).to eq("b1b5fdf6-3f1c-4867-8dd4-8822617fda64")
    end
  end
end
