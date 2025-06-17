require 'json'
require 'open-uri'
require 'fileutils'
require_relative '../services/parse_schedule_xlsx_service'

class ScheduleController
  def initialize(bot, token)
    @bot = bot
    @token = token
  end

  # Обробка завантаження файлу розкладу
  def handle_schedule_upload(message, user)
    document = message.document

    unless document&.mime_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      @bot.api.send_message(chat_id: message.chat.id, text: 'Некоректний файл. Будь ласка, надішліть XLSX файл.')
      user.update(state: nil)
      return
    end

    # Видаляємо старі файли розкладу
    Dir.glob(File.join('storage', 'schedule_*.xlsx')).each do |file|
      File.delete(file)
    rescue StandardError
      nil
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

        # Парсимо розклад через сервіс
        parsed_schedule = ParseScheduleXlsxService.new(save_path).call

        # Зберігаємо у JSON файл
        File.write('storage/merged_schedule.json', JSON.pretty_generate(parsed_schedule))

        user.update(state: nil)
        @bot.api.send_message(chat_id: message.chat.id, text: 'Файл успішно збережено та розклад оновлено.')
      else
        @bot.api.send_message(chat_id: message.chat.id,
                              text: "Помилка отримання файлу з Telegram: #{response['description']}")
      end
    rescue StandardError => e
      @bot.api.send_message(chat_id: message.chat.id, text: "Помилка при завантаженні файлу: #{e.message}")
    end
  end
end
