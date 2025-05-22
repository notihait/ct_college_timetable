require 'telegram/bot'
require 'active_record'

class Dispatcher
  def initialize(bot)
    @bot = bot
    @user_states = {}
  end

  def process_message(message)
    case message.text
    when '/start'
      @bot.api.send_message(chat_id: message.chat.id, text: "Привет! Я бот.")
    else
      @bot.api.send_message(chat_id: message.chat.id, text: "Вы написали: #{message.text}")
    end
  end
end
