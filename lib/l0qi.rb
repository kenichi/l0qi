require 'bundler'
Bundler.require

require 'l0qi/karma'
require 'l0qi/pics'

module L0qi

  R = ConnectionPool.new do
    Redis.new driver: :celluloid, namespace: 'l0qi'
  end

  BOT = Cinch::Bot.new do
    configure do |c|
      c.channels = ['##l0qi_testing', '#exesri']
      c.nick = 'l0qi'
      c.server = '185.30.166.38'
      c.plugins.plugins = [
        Karma::Giver,
        Karma::Checker,
        Pics
      ]
    end
  end

end
