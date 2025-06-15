require 'json'
require 'open-uri'

class ScheduleController
  def initialize(bot, token)
    @bot = bot
    @token = token
  end

  def handle_schedule_upload(message, user)
    document = message.document

    unless document&.mime_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      @bot.api.send_message(chat_id: message.chat.id, text: "Будь ласка, надішліть файл у форматі .xlsx.")
      return
    end

    file_id = document.file_id

    url = "https://api.telegram.org/bot#{@token}/getFile?file_id=#{file_id}"

    begin
      response_json = URI.open(url).read
      response = JSON.parse(response_json)

      if response['ok']
        file_path = response['result']['file_path']
        file_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"

        save_path = File.join('storage', "schedule_#{Time.now.to_i}.xlsx")

        URI.open(file_url) do |file|
          File.open(save_path, 'wb') { |f| f.write(file.read) }
        end

        user.update(state: nil)
        @bot.api.send_message(chat_id: message.chat.id, text: "Файл успішно збережено: #{save_path}")
      else
        @bot.api.send_message(chat_id: message.chat.id, text: "Помилка отримання файлу з Telegram: #{response['description']}")
      end
    rescue => e
      @bot.api.send_message(chat_id: message.chat.id, text: "Помилка при завантаженні файлу: #{e.message}")
    end
  end

  def send_schedule(chat_id, user_id)
    user = User.find_by(telegram_id: user_id)
    unless user&.group_id
      @bot.api.send_message(chat_id: chat_id, text: "Не вказана група користувача.")
      return
    end

    group = Group.find_by(id: user.group_id)
    unless group
      @bot.api.send_message(chat_id: chat_id, text: "Групу не знайдено.")
      return
    end

    json_path = File.join('storage', 'timetable.json')
    unless File.exist?(json_path)
      @bot.api.send_message(chat_id: chat_id, text: "Файл з розкладом не знайдено.")
      return
    end

    timetable = JSON.parse(File.read(json_path))
    group_schedule = timetable[group.group_name]
    unless group_schedule
      @bot.api.send_message(chat_id: chat_id, text: "Розклад для групи #{group.group_name} не знайдено.")
      return
    end

    text = "Розклад для групи #{group.group_name}:\n\n"
    group_schedule['days'].each do |day|
      text << "#{day['name']}:\n"
      day['lessons'].each do |lesson|
        subjects_text = lesson['subjects'].map { |s| "#{s['subject']} (#{s['teacher']})" }.join(', ')
        text << "  #{lesson['lesson']}. #{subjects_text}\n"
      end
      text << "\n"
    end

    @bot.api.send_message(chat_id: chat_id, text: text)
  end
end
