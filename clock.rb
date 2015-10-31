require 'clockwork'
require './notifier.rb'

module Clockwork
  handler do |job|
    case job
    when 'poll'
      Notifier::poll
    end
  end

  every(30.minutes, 'poll')
end
