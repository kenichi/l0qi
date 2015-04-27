require 'date'

module L0qi
  class Pics
    class Cmd
      include Cinch::Plugin

      LIST_REPLY = "(%d) - %s - %s - %s"

      match /^!pics (.*)$/, use_prefix: false

      def clear!
        R.del LIST_KEY
      end

      def list m
        R.with do |r|
          l = r.llen LIST_KEY
          r.lrange(LIST_KEY, 0, l - 1).each_with_index do |p, i|
            p = JSON.parse p
            m.reply LIST_REPLY % [
              i,
              p['nick'],
              p['url'],
              Time.at(p['time']).iso8601
            ]
          end
        end
      end

      def pop m, i
        i = i.nil? ? 0 : Integer(i)
        R.with do |r|
          c = r.llen LIST_KEY
          ps = r.lrange LIST_KEY, 0, c - 1
          r.del LIST_KEY
          ps.each_with_index do |p, _i|
            if _i == i
              m.reply p
            else
              r.rpush LIST_KEY, p
            end
          end
        end
      end

      def execute m, cmd
        cmds = cmd.split /\s+/
        case cmds[0]
        when 'clear'; clear!
        when 'count'; m.reply "#{R.llen LIST_KEY} pics in history"
        when 'list'; list m
        when 'pop'; pop m, cmds[1]
        end
      end

    end
  end
end
