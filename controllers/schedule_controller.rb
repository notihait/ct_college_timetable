class ScheduleController
    def initialize(bot)
      @bot = bot
    end
  
    def send_schedule(chat_id, telegram_id)
        user = User.find_by(telegram_id: telegram_id)
        @bot.api.send_message(chat_id: chat_id, text: "Здесь будет ваше расписание, #{user.first_name}")
      end
      
  end
  