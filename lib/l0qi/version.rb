module L0qi

  VERSION = '0.6.8'
  START = Time.now

  class Version
    include Cinch::Plugin

    match 'version'

    def execute m
      m.reply "L0qi (#{VERSION})"
      m.reply "nick: #{CONFIG[:nick]} in channels: #{CONFIG[:channels].join(',')}"
      m.reply "uptime: #{Time.now - START}s"
    end

  end
end
