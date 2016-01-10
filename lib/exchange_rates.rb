require 'money/bank/open_exchange_rates_bank'
require 'active_support/all'

moe = Money::Bank::OpenExchangeRatesBank.new
moe.ttl_in_seconds = 1.months / 2000
moe.app_id = ENV.fetch('OPEN_EXCHANGE_RATES_APP_ID')
moe.update_rates
Money.default_bank = moe
