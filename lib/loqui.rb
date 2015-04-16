require 'bundler'
Bundler.require

require 'loqui/karma'

module Loqui

  R = ConnectionPool.new do
    Redis.new driver: :celluloid, namespace: 'loqui'
  end

  BOT = Cinch::Bot.new do
    configure do |c|
      c.channels = ['##loqui_testing']
      c.nick = 'loqui'
      c.server = 'chat.freenode.net'
      c.plugins.plugins = [Karma::Giver, Karma::Checker]
    end
  end

end
