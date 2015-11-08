module L0qi

  VERSION = '0.8.0'
  START = Time.now

  class Version
    include Cinch::Plugin

    match 'version'

    def execute m
      m.reply "L0qi (#{VERSION})"
      m.reply "nick: #{CONFIG[:nick]}"
      m.reply "uptime: #{(Time.now - START).round}s"
      m.reply "URL history: #{R.llen Urls::LIST_KEY}"
    end

  end
end
