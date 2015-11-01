require 'clockwork'
require 'chronic_duration'
require './lib/notifier.rb'

POLLING_INTERVAL = ENV.fetch('POLLING_INTERVAL', '10 minutes')

module Clockwork
  handler do |job|
    case job
    when 'poll'
      Notifier::poll
    end
  end

  every(ChronicDuration.parse(POLLING_INTERVAL).seconds, 'poll')
end
