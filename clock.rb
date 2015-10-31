require 'clockwork'
require 'chronic_duration'
require './notifier.rb'

module Clockwork
  handler do |job|
    case job
    when 'poll'
      Notifier::poll
    end
  end

  every(ChronicDuration.parse(ENV['POLLING_INTERVAL']).seconds, 'poll')
end
