require 'bundler'
Bundler.require
require 'yaml'

module L0qi

  CONFIG_FILE = File.expand_path '../../config.yml', __FILE__
  begin
    CONFIG = YAML.load_file CONFIG_FILE
  rescue => e
    STDERR.puts "unable to read: #{CONFIG_FILE}"
    exit 1
  end

  require 'l0qi/karma'
  require 'l0qi/pics'

  R = ConnectionPool.new do
    Redis::Namespace.new :l0qi, redis: Redis.new(driver: :celluloid)
  end

  BOT = Cinch::Bot.new do
    configure do |c|
      c.channels = CONFIG[:channels]
      c.nick = CONFIG[:nick]
      c.server = CONFIG[:server]
      c.plugins.plugins = [
        Karma::Giver,
        Karma::Checker,
        Pics
      ]
    end
  end

end
