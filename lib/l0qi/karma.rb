module L0qi
  module Karma

    HKEY = 'karma'
    REPLY = '%s has %d karma'
    UP_SAME_NICK = '%s: really?'
    DOWN_SAME_NICK = '%s: <3'
    KARMA_REGEX = /([^\+\-\s]+)(\+\+|\-\-)/

  end
end

require 'l0qi/karma/checker'
require 'l0qi/karma/giver'
