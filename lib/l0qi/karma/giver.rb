module L0qi
  module Karma
    class Giver
      include Cinch::Plugin

      match /(^.*\s|^)(\S+)(\+\+|\-\-).*$/, use_prefix: false

      def execute m, _, nick, mod
        case
        when m.user.nick == nick
          case mod
          when '++'; m.reply UP_SAME_NICK % nick
          when '--'; m.reply DOWN_SAME_NICK % nick
          end
        when m.channel.has_user?(nick)
          by = case mod
               when '++'; 1
               when '--'; -1
               end
          k = R.with {|r| r.hincrby HKEY, nick, by}
          m.reply REPLY % [nick, k]
        end
      end

    end
  end
end
