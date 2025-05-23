class AdminController
  def initialize(bot)
    @bot = bot
  end

  def start_group_creation(message)
    user = User.find_by(telegram_id: message.from.id)
    return unless user

    user.update(state: 'awaiting_group_name')
    @bot.api.send_message(chat_id: message.chat.id, text: "Введите название новой группы:")
  end

  def handle_group_creation(message)
    user = User.find_by(telegram_id: message.from.id)
    group_name = message.text.strip

    if group_name.empty?
      @bot.api.send_message(chat_id: message.chat.id, text: "Название группы не может быть пустым.")
      return
    end

    if Group.exists?(group_name: group_name)
      @bot.api.send_message(chat_id: message.chat.id, text: "Группа уже существует.")
    else
      Group.create(group_name: group_name)
      @bot.api.send_message(chat_id: message.chat.id, text: "Группа '#{group_name}' успешно добавлена.")
    end

    user.update(state: nil)
  end
end
