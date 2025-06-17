#!/usr/bin/env ruby
# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
Dotenv.load

require_relative 'core/telegram_bot'
require_relative 'core/dispatcher'
require_relative 'db/config' # обязательно, чтобы подключить базу

puts "Token: #{ENV['TELEGRAM_TOKEN'].inspect}"
token = ENV['TELEGRAM_TOKEN']

if ARGV.include? 'console'
  binding.pry
else
  Core::TelegramBot.new(ENV['TELEGRAM_TOKEN']).run
end
