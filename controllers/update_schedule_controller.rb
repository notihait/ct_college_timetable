class UpdateScheduleConroller
  def initialize(bot)
    @bot = bot
  end

  def update_schedule(_chat_id, _telegram_id)
    user = User.find_by(telegram_id: message.from.id)

    user.update(state: 'waiting_for_schedule_update')
  end
end
