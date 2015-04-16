#!/usr/bin/env ruby

require 'bundler'
Bundler.require

kato = Cinch::Bot.new do

  configure do |c|
    c.channels = ['##kato_testing']
    c.nick = 'kato'
    c.server = 'chat.freenode.net'
  end

  on :message, /^.*(\S+)\+\+.*$/ do |m, nick|
    binding.pry
  end

end

kato.start
