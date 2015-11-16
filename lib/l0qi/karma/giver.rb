module L0qi
  module Karma
    class Giver
      include Cinch::Plugin

      PHP = 'php'

      DEFAULT_ALIAS = ->(nick){ /#{nick}_+/ }

      def initialize *a
        super
        L0qi::Web.on_ws_messages(:url) << method(:on_ws_message)
      end

      match /(\+\+|\-\-)/, use_prefix: false

      def same_nick m, nick, mod
        case mod
        when '++'; m.reply UP_SAME_NICK % nick
        when '--'; m.reply DOWN_SAME_NICK % nick
        end
      end

      def check_aliases key
        CONFIG[:plugins][:karma][:aliases].each do |nick, aliases|
          return nick if aliases.include? key
        end

        matches = R.hkeys(HKEY).select {|k| key =~ DEFAULT_ALIAS[k]}
        return matches.first unless matches.empty?
        return key
      end

      def give m, key, mod
        if key.downcase == PHP
          m.reply "nope."
        else
          by = case mod
               when '++'; 1
               when '--'; -1
               end
          k = R.hincrby HKEY, key, by
          m.reply REPLY % [key, k]
        end
      end

      def each m, key, mod
        key = check_aliases key
        if m.user.nick == key
          same_nick m, key, mod
        else
          give m, key, mod
        end
      end

      def execute m
        Hash[m.message.scan KARMA_REGEX].each {|k,mod| each m, k, mod}
      end

      private

      def on_ws_message ws, msg
        if msg['type'] == 'karma'
          n, c = msg['nick'], msg['channel']
          unless n.empty? or c.empty?
            n = check_aliases n
            k = R.hincrby HKEY, n, 1
            L0qi.Channel(c).send((REPLY % [n, k]) + ' via websocket!')
          end
        end
      end

    end
  end
end
