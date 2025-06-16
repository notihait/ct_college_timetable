require_relative '../models/user'
require_relative '../models/group'
require_relative '../models/timetable'
require_relative '../models/subject'
require_relative '../models/teacher'
require_relative '../core/keyboards'
require_relative '../lib/admin_checker'
require_relative '../controllers/schedule_controller'
require_relative '../controllers/update_schedule_controller'
require_relative '../controllers/admin_controller'
require_relative '../controllers/day_of_week_controller'
require_relative '../controllers/group_import_controller'


class Dispatcher
  include AdminChecker

  def initialize(bot, token)
    @bot = bot
    @token = token
    @schedule_controller = ScheduleController.new(bot, token)
    @admin_controller = AdminController.new(bot)
    @day_of_week_controller = DayOfWeekController.new
  end

  def show_main_menu(chat_id, telegram_id)
    is_admin = admin?(telegram_id)
    keyboard = Core::Keyboards.user_main_menu_keyboard(is_admin: is_admin)

    @bot.api.send_message(
      chat_id: chat_id,
      text: "Головне меню:",
      reply_markup: keyboard
    )
  end

  def show_admin_menu(chat_id, telegram_id)
    keyboard = Core::Keyboards.admin_menu_keyboard

    @bot.api.send_message(
      chat_id: chat_id,
      text: "Адмін-панель:",
      reply_markup: keyboard
    )
  end

  def process_message(message)
    puts "Обработка: #{message.text}"

    user = User.find_by(telegram_id: message.from.id)

    if user&.state == 'awaiting_schedule_file' || user&.state == 'awaiting_schedule_upload'
      @schedule_controller.handle_schedule_upload(message, user)
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
      show_main_menu(chat_id, message.from.id)

    when 'Обрати групу'
      groups = Group.all
      keyboard = Core::Keyboards.group_selection_keyboard(groups)
      @bot.api.send_message(
        chat_id: message.chat.id,
        text: "Оберіть групу:",
        reply_markup: keyboard
      )

    when 'Мій розклад'
      @bot.api.send_message(
        chat_id: message.chat.id,
        text: "Оберіть день тижня:",
        reply_markup: Core::Keyboards.days_keyboard
      )
      user.update(state: nil) if user

    when 'Хто я?'
      @bot.api.send_message(chat_id: message.chat.id, text: "Ви: #{user.inspect}")

    when 'Адмін-панель'
      if admin?(message.from.id)
        show_admin_menu(message.chat.id, message.from.id)
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "У вас немає доступу.")
      end

    when 'Додати групу'
      if admin?(message.from.id)
        puts "Запускаємо створення групи для користувача #{message.from.id}"
        @admin_controller.start_group_creation(message)
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "У вас немає доступу.")
      end
    
    when 'Імпорт груп з таблиці'
      if admin?(message.from.id)
        controller = GroupImportController.new
        count = controller.import_groups
        @bot.api.send_message(chat_id: message.chat.id, text: "Імпортовано #{count} груп.")
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "У вас немає доступу.")
      end

      
    when 'Список груп'
      @admin_controller.list_groups(message)

    when 'Додати заміни'
  if admin?(message.from.id)
    user.update(state: 'awaiting_changes_upload') if user
    @bot.api.send_message(chat_id: message.chat.id, text: "Будь ласка, надішліть файл із замінами у форматі .docx.")
  else
    @bot.api.send_message(chat_id: message.chat.id, text: "У вас немає доступу.")
  end


    when 'Оновити розклад'
      if admin?(message.from.id)
        user.update(state: 'awaiting_schedule_upload') if user
        @bot.api.send_message(chat_id: message.chat.id, text: "Будь ласка, надішліть файл у форматі .xlsx.")
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "У вас немає доступу.")
      end

    else
      show_main_menu(message.chat.id, message.from.id)
    end
  end

  def process_callback_query(update)
    @bot.api.answer_callback_query(callback_query_id: update.id)
    puts "CallbackQuery ID: #{update.id.inspect}"
    puts "CallbackQuery data: #{update.data.inspect}"

    data = update.data
    chat_id = update.message.chat.id
    telegram_id = update.from.id
    user = User.find_by(telegram_id: telegram_id)


    case data
    when /^group_(\d+)$/
      group_id = $1.to_i
      group = Group.find_by(id: group_id)
      if group
        user.update(group_id: group_id) if user
        @bot.api.send_message(chat_id: chat_id, text: "Ви обрали групу #{group.group_name}")
      else
        @bot.api.send_message(chat_id: chat_id, text: "Групу не знайдено.")
      end

    when /^day_(\d+)$/
      day_number = $1.to_i

      unless user && user.group_id
        @bot.api.send_message(chat_id: chat_id, text: "Будь ласка, спочатку оберіть групу командою 'Обрати групу'.")
        return
      end

      group = Group.find_by(id: user.group_id)
      unless group
        @bot.api.send_message(chat_id: chat_id, text: "Групу не знайдено, будь ласка, оберіть групу знову.")
        return
      end

      schedule_text = @day_of_week_controller.get_schedule_for_day(day_number, group.group_name)
      @bot.api.send_message(chat_id: chat_id, text: schedule_text)

    else
      @bot.api.send_message(chat_id: chat_id, text: "Невідомий callback: #{data}")
    end
  end
end
