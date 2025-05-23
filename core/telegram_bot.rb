module Core
    class TelegramBot
      attr_reader :bot
  
      def initialize(token)
        @token = token
        @bot = Telegram::Bot::Client.new(@token)
      end
  
      def run
        puts "Бот запускается..."
        @bot.run do |bot|
          puts "Бот запущен!"
          @dispatcher = Dispatcher.new(bot)
      
          bot.listen do |update|
            if update.is_a?(Telegram::Bot::Types::Message)
              @dispatcher.process_message(update)
            elsif update.is_a?(Telegram::Bot::Types::CallbackQuery)
              @dispatcher.process_callback_query(update)
            else
              # логи
              puts "Unknown update type: #{update.class}"
            end
          end
          
        end
      end
      
    end
  end
  