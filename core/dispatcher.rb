require_relative '../models/user'
require_relative '../models/group'
require_relative '../models/timetable'
require_relative '../models/subject'
require_relative '../models/teacher'
require_relative '../core/keyboards'
require_relative '../lib/admin_checker' 
require_relative '../controllers/schedule_controller'

class Dispatcher
  include AdminChecker

  def initialize(bot)
    @bot = bot
    @schedule_controller = ScheduleController.new(bot)
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
  
  

  def process_message(message)
    puts "Обработка: #{message.text}"
  
    case message.text
    when '/start', '🏁 Старт'
      user = User.find_by(telegram_id: message.from.id)
      show_main_menu(message.chat.id, message.from.id)
      @bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{user.first_name}!")
        
  
    when 'Выбрать группу'
      groups = Group.all
      keyboard = Core::Keyboards.group_selection_keyboard(groups)
      @bot.api.send_message(
        chat_id: message.chat.id,
        text: "Выберите группу:",
        reply_markup: keyboard
      )
  
    when 'Мое расписание'
      @schedule_controller.send_schedule(message.chat.id, message.from.id)
  
    when 'Кто я'
      user = User.find_by(telegram_id: message.from.id)
      @bot.api.send_message(chat_id: message.chat.id, text: "Вы: #{user.inspect}")
  
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
      group = Group.find(group_id)
      @bot.api.send_message(chat_id: chat_id, text: "Вы выбрали группу #{group.group_name}")

    else
      @bot.api.send_message(chat_id: chat_id, text: "Неизвестный callback: #{data}")
    end
  
    @bot.api.answer_callback_query(callback_query_id: update.id)
end
  
  
  
  
end
