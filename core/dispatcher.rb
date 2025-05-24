require_relative '../models/user'
require_relative '../models/group'
require_relative '../models/timetable'
require_relative '../models/subject'
require_relative '../models/teacher'
require_relative '../core/keyboards'
require_relative '../lib/admin_checker'
require_relative '../controllers/schedule_controller'
require_relative '../controllers/admin_controller'

class Dispatcher
  include AdminChecker

  def initialize(bot)
    @bot = bot
    @schedule_controller = ScheduleController.new(bot)
    @admin_controller = AdminController.new(bot)
  end

  def show_main_menu(chat_id, telegram_id)
    is_admin = admin?(telegram_id)
    keyboard = Core::Keyboards.user_main_menu_keyboard(is_admin: is_admin)

    @bot.api.send_message(
      chat_id: chat_id,
      text: "Главное меню:",
      reply_markup: keyboard
    )
  end

  def show_admin_menu(chat_id, telegram_id)
    keyboard = Core::Keyboards.admin_menu_keyboard

    @bot.api.send_message(
      chat_id: chat_id,
      text: "Админ-панель:",
      reply_markup: keyboard
    )
  end

  def process_message(message)
    puts "Обработка: #{message.text}"
  
    user = User.find_by(telegram_id: message.from.id)
  
    # Обработка состояния — при ожидании названия группы, передаем в админ контроллер
    if user&.state == 'awaiting_group_name'
      @admin_controller.handle_group_creation(message)

    puts "Пользователь #{user.telegram_id} в режиме ожидания названия группы"
      return
    end
  
    case message.text
    when '/start'
      chat_id = message.chat.id
      @bot.api.send_message(chat_id: chat_id, text: "Вітаю!")
      unless user
        User.create(
          telegram_id: message.from.id,
          first_name: message.from.first_name
        )
      end
  
    when 'Выбрать группу'
      groups = Group.all
      keyboard = Core::Keyboards.group_selection_keyboard(groups)
      @bot.api.send_message(
        chat_id: message.chat.id,
        text: "Выберите группу:",
        reply_markup: keyboard
      )
  
    when 'Админ-панель'
      if admin?(message.from.id)
        show_admin_menu(message.chat.id, message.from.id)
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "У вас нет доступа.")
      end
    
    when 'Добавить группу'
      if admin?(message.from.id)
        puts "Запускаем создание группы для пользователя #{message.from.id}"
        @admin_controller.start_group_creation(message)
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "У вас нет доступа.")
      end
    
    when 'Список групп'
      @admin_controller.list_groups(message)
  
    else
      show_main_menu(message.chat.id, message.from.id)
    end
  end
  

  def process_callback_query(update)
    puts "CallbackQuery ID: #{update.id.inspect}"
    puts "CallbackQuery data: #{update.data.inspect}"
    data = update.data
    chat_id = update.message.chat.id
    telegram_id = update.from.id

    case data
    when /^group_(\d+)$/
      group_id = $1.to_i
      group = Group.find_by(id: group_id)
      if group
        @bot.api.send_message(chat_id: chat_id, text: "Вы выбрали группу #{group.group_name}")
      else
        @bot.api.send_message(chat_id: chat_id, text: "Группа не найдена.")
      end

    else
      @bot.api.send_message(chat_id: chat_id, text: "Неизвестный callback: #{data}")
    end

    @bot.api.answer_callback_query(callback_query_id: update.id)
  end
end
