#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative 'core/telegram_bot'
require 'telegram/bot' # если ты ещё не подключил библиотеку
require_relative 'core'
require_relative 'core/dispatcher'

puts "Token: #{ENV['TELEGRAM_TOKEN'].inspect}"

Core.require_source
if ARGV.include? 'console'
  binding.pry
else
  Core::TelegramBot.new(ENV['TELEGRAM_TOKEN']).run
end
