require 'bundler'
Bundler.require

require 'l0qi/karma'

module L0qi

  R = ConnectionPool.new do
    Redis.new driver: :celluloid, namespace: 'l0qi'
  end

  BOT = Cinch::Bot.new do
    configure do |c|
      c.channels = ['##l0qi_testing']
      c.nick = 'l0qi'
      c.server = '185.30.166.38'
      c.plugins.plugins = [Karma::Giver, Karma::Checker]
    end
  end

end
