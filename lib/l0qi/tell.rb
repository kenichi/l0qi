module L0qi
  class Tell
    include Cinch::Plugin

    USER_MESSAGES = 'user_messages:%s'.freeze
    TELL_REGEX = /^!tell (\S+) (.*)$/
    SAVED = "noted. will do.".freeze
    YOURSELF = "why don't you tell them yourself?".freeze

    match /tell.*/

    listen_to :online, method: :on_online
    listen_to :connect, method: :on_connect

    def execute m
      if md = TELL_REGEX.match(m.message)
        user, msg = md[1], md[2]
        if User(user).online?
          m.reply YOURSELF
        else
          R.rpush USER_MESSAGES % user, {
            at: Time.now,
            channel: m.channel,
            from: m.user.nick,
            message: msg
          }.to_json
          User(user).monitor unless User(user).monitored?
          m.reply SAVED
        end
      end
    end

    def check_messages user
      key = USER_MESSAGES % user
      R.llen(key) > 0 ? key : nil
    end

    def on_connect user
      R.keys(USER_MESSAGES % '*').each do |k|
        if R.llen(k) > 0
          User(k.sub('user_messages:', '')).monitor
        end
      end
    end

    def on_online m, user
      if key = check_messages(user)
        while msg = (JSON.parse(R.lpop(key)) rescue nil)
          Channel(msg['channel']).send "#{user}: #{msg['from']} left you a message at #{msg['at']} -"
          Channel(msg['channel']).send "#{user}: #{msg['message']}"
        end
      else
        User(user).unmonitor
      end
    end

  end
end
