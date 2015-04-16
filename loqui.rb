#!/usr/bin/env ruby

require 'bundler'
Bundler.require

module Loqui

  class Karma
    include Cinch::Plugin
    match /(^.*\s|^)(\S+)\+\+.*$/
    def execute m, _, nick
      binding.pry
    end
  end

  BOT = Cinch::Bot.new do

    configure do |c|
      c.channels = ['##loqui_testing']
      c.nick = 'loqui'
      c.server = 'chat.freenode.net'
      c.plugins.plugins = [Karma]
    end

  end

end

Loqui::BOT.start
