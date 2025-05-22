require_relative '../models/user'
require_relative '../models/group'
require_relative '../models/timetable'
require_relative '../models/subject'
require_relative '../models/teacher'
require_relative '../core/keyboards'

class Dispatcher
  def initialize(bot)
    @bot = bot
  end

  def process_message(message)
    puts "Получено: #{message.text}"
    case message.text
    when '/start'
      user = User.find_or_create_by(telegram_id: message.from.id) do |u|
        u.first_name = message.from.first_name
        u.role = 'student'
      end
      @bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{user.first_name}!")

    when '/my_schedule'
      user = User.find_by(telegram_id: message.from.id)

      if user&.group_id.nil?
        @bot.api.send_message(chat_id: message.chat.id, text: "Вы не выбрали группу.")
        return
      end

      timetables = Timetable.includes(:subject, :teacher)
                            .where(group_id: user.group_id)
                            .order(:day_of_week, :lesson_order)

      if timetables.empty?
        @bot.api.send_message(chat_id: message.chat.id, text: "404")
      else
        message_text = timetables.map do |tt|
          day = %w[Понедельник Вторник Среда Четверг Пятница Суббота Воскресенье][tt.day_of_week.to_i]
          "#{day}, урок №#{tt.lesson_order}: #{tt.subject.subject_name} (#{tt.teacher.teacher_name})"
        end.join("\n")

        @bot.api.send_message(chat_id: message.chat.id, text: message_text)
      end

    when '/whoami'
      user = User.find_by(telegram_id: message.from.id)
      @bot.api.send_message(chat_id: message.chat.id, text: "Вы: #{user.inspect}")

    when '/select'
      groups = Group.all
      keyboard = Core::Keyboards.group_selection_keyboard(groups)

      @bot.api.send_message(
        chat_id: message.chat.id,
        text: "Выберите группу:",
        reply_markup: keyboard
      )

    else
      @bot.api.send_message(chat_id: message.chat.id, text: "Вы написали: #{message.text}")
    end
  end

  def process_callback_query(callback_query)
    data = callback_query.data
  
    if data =~ /^group_(\d+)$/
      group_id = $1.to_i
      user = User.find_or_create_by(telegram_id: callback_query.from.id)
      user.group_id = group_id
      user.save!
  
      @bot.api.send_message(
        chat_id: callback_query.from.id,
        text: "Вы выбрали группу #{Group.find(group_id).group_name}"
      )
  
    else
      @bot.api.send_message(
        chat_id: callback_query.from.id,
        text: "Неизвестная команда."
      )
    end
  end
  
  
end
