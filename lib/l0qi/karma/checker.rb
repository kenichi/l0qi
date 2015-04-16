module L0qi
  module Karma
    class Checker
      include Cinch::Plugin

      match /^karma($|\s(\S+))$/

      def execute m, nick, _
        nick ||= m.user.nick
        if k = R.with {|r| r.hget HKEY, nick}
          m.reply REPLY % [nick, k]
        end
      end

    end
  end
end
