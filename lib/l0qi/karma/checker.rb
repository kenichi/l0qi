module L0qi
  module Karma
    class Checker
      include Cinch::Plugin

      match /karma\s*(\S*)$/

      def execute m, nick
        nick = m.user.nick if nick.empty?
        if k = R.with {|r| r.hget HKEY, nick}
          m.reply REPLY % [nick, k]
        elsif m.channel.has_user? nick
          m.reply REPLY % [nick, 0]
        end
      end

    end
  end
end
