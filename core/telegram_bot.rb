# frozen_string_literal: true

module Core
    class TelegramBot
      attr_reader :bot
  
      def initialize(token)
        @token = token
        @bot = Telegram::Bot::Client.new(@token)
      end
  
      def run
        @bot.run do |bot|
          @dispatcher = Dispatcher.new(bot)
          bot.listen do |message|
            @dispatcher.process_message(message)
          end
        end
      end
    end
  end