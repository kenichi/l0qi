#!/usr/bin/env ruby

require 'bundler'
Bundler.require

module Loqui

  R = ConnectionPool.new do
    Redis.new driver: :celluloid, namespace: 'loqui'
  end

  module Karma

    HKEY = 'karma'
    REPLY = '%s has %d karma'

    class Checker
      include Cinch::Plugin

      match /^karma($|\s(\S+))$/

      def execute m, nick, _
        nick ||= m.user.nick
        if k = R.with {|r| r.hget HKEY, nick}
          m.reply REPLY % [nick, k]
        end
      end

    end

    class Giver
      include Cinch::Plugin

      match /(^.*\s|^)(\S+)(\+\+|\-\-).*$/, use_prefix: false

      def execute m, _, nick, mod
        case
        when m.user.nick == nick
          m.reply "really?"
        when m.channel.has_user?(nick)
          by = case mod
               when '++'; 1
               when '--'; -1
               end
          k = R.with {|r| r.hincrby HKEY, nick, by}
          m.reply REPLY % [nick, k]
        end
      end

    end

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

Loqui::BOT.start
