class UpdateScheduleConroller
    def initialize(bot)
      @bot = bot
    end

    def update_schedule(chat_id, telegram_id)
        user = User.find_by(telegram_id: message.from.id)

        user.update(state: 'waiting_for_schedule_update')


    end
end