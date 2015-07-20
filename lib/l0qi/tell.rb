module L0qi
  class Tell
    include Cinch::Plugin

    USER_MESSAGES = 'user_messages:%s'.freeze
    TELL_REGEX = /^!tell (\S+) (.*)$/
    SAVED = "noted. will do.".freeze
    YOURSELF = "why don't you tell them yourself?".freeze

    match /tell.*/

    listen_to :online, method: :on_online

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
          m.reply SAVED
        end
      end
    end

    def on_online m, user
      l = USER_MESSAGES % user.nick
      len = R.llen l
      if len > 0
        while msg = R.lpop(l)
          msg = JSON.parse msg
          msg = [
            "#{user}: #{msg['from']} left you a message at #{msg['at']} -",
            "#{user}: #{msg['message']}"
          ]
          msg.each {|_| Channel(msg['channel']).send _}
        end
      end
    end

  end
end
