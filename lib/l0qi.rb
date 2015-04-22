require 'bundler'
Bundler.require
require 'forwardable'
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
  require 'l0qi/version'

  R = Module.new do
    class << self
      extend Forwardable
      def_delegator :redis, :with
      def redis &block
        @redis ||= ConnectionPool.new do
          Redis::Namespace.new :l0qi, redis: Redis.new(driver: :celluloid)
        end
      end
      def multi &block
        with {|_r| _r.multi {|r| block[r]}}
      end
      def method_missing m, *a
        with {|r| r.__send__ m, *a}
      end
    end
  end

  class << self
    include Cinch::Helpers

    def report msg
      Channel(CONFIG[:report]).send msg
    end

    def bot
      unless @bot
        @bot = Cinch::Bot.new do
          configure do |c|
            c.channels = (CONFIG[:channels] + [CONFIG[:report]]).uniq
            c.nick = CONFIG[:nick]
            c.plugins.plugins = [
              Karma::Giver,
              Karma::Checker,
              Pics,
              Pics::Cmd,
              Version
            ]
            c.server = CONFIG[:server]
          end
        end

        if CONFIG[:log_file]
          root = File.expand_path '../..', __FILE__
          log_file = File.open File.join(root, CONFIG[:log_file]), "a"
          @bot.loggers[0] = Cinch::Logger::FormattedLogger.new(log_file)
          Celluloid.logger = Logger.new log_file
        end
      end
      @bot
    end
  end

end
