require 'open-uri'
require 'json'
require 'docx'
require_relative '../services/parse_schedule_changes_service'
require_relative '../controllers/merge_timetable_controller'

class ChangesController
  MAIN_SCHEDULE_PATH = File.join('storage', 'merged_schedule.json')

  def initialize(bot, token)
    @bot = bot
    @token = token
  end

  def handle_changes_upload(message, user)
    document = message.document

    unless document
      user.update(state: nil)
      @bot.api.send_message(chat_id: message.chat.id, text: 'Файл не знайдено в повідомленні.')
      return
    end

    unless document.file_name&.downcase&.end_with?('.docx')
      user.update(state: nil)
      @bot.api.send_message(chat_id: message.chat.id, text: 'Будь ласка, надішліть файл із замінами у форматі .docx.')
      return
    end

    begin
      file_id = document.file_id
      file_info_url = "https://api.telegram.org/bot#{@token}/getFile?file_id=#{file_id}"
      file_info_response = URI.open(file_info_url).read
      file_info = JSON.parse(file_info_response)

      unless file_info['ok']
        user.update(state: nil)
        @bot.api.send_message(chat_id: message.chat.id, text: "Помилка отримання файлу: #{file_info['description']}")
        return
      end

      Dir.glob(File.join('storage', 'changes_*.docx')).each do |file|
        File.delete(file)
      rescue StandardError
        nil
      end
      file_path = file_info['result']['file_path']
      file_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"
      save_path = File.join('storage', "changes_#{Time.now.to_i}.docx")

      URI.open(file_url) do |remote_file|
        File.open(save_path, 'wb') { |f| f.write(remote_file.read) }
      end

      # Парсимо заміни з docx
      parsed_changes = ParseScheduleChangesService.new(save_path).call

      # Читаємо основний розклад
      main_schedule = if File.exist?(MAIN_SCHEDULE_PATH)
                        JSON.parse(File.read(MAIN_SCHEDULE_PATH))
                      else
                        {}
                      end

      # Зливаємо основний розклад і заміни
      merged_schedule = MergeTimetableController.new(main_schedule, parsed_changes).merge

      # Зберігаємо оновлений розклад у той самий файл
      File.write(MAIN_SCHEDULE_PATH, JSON.pretty_generate(merged_schedule))

      user.update(state: nil)
      @bot.api.send_message(chat_id: message.chat.id, text: 'Заміни збережено, оброблено та розклад оновлено.')
    rescue StandardError => e
      user.update(state: nil)
      @bot.api.send_message(chat_id: message.chat.id, text: "Помилка при обробці замін: #{e.message}")
    end
  end
end
