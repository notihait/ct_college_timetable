#require 'json'
#require 'open-uri'
#require 'docx'
#
#class ChangesController
#  def initialize(bot, token)
#    @bot = bot
#    @token = token
#  end
#
#  def handle_changes_upload(message, user)
#    document = message.document
#
#    unless document&.mime_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
#      @bot.api.send_message(chat_id: message.chat.id, text: "Будь ласка, надішліть файл зі змінами у форматі .docx.")
#      return
#    end
#    if user&.state == 'awaiting_changes_upload'
#  @changes_controller.handle_changes_upload(message, user)
#  return
#    begin
#      response_json = URI.open(url).read
#      response = JSON.parse(response_json)
#
#      if response['ok']
#        file_path = response['result']['file_path']
#        file_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"
#
#        save_path = File.join('storage', "changes_#{Time.now.to_i}.docx")
#
#        URI.open(file_url) do |file|
#          File.open(save_path, 'wb') { |f| f.write(file.read) }
#        end
#
#        parse_changes_docx(save_path)
#
#        user.update(state: nil)
#        @bot.api.send_message(chat_id: message.chat.id, text: "Зміни успішно збережені.")
#      else
#        @bot.api.send_message(chat_id: message.chat.id, text: "Помилка отримання файлу: #{response['description']}")
#      end
#    rescue => e
#      @bot.api.send_message(chat_id: message.chat.id, text: "Помилка при обробці файлу: #{e.message}")
#    end
#  end
#
#  def parse_changes_docx(path)
#    doc = Docx::Document.open(path)
#    table = doc.tables.first
#    return unless table
#
#    result = []
#
#    table.rows.each_with_index do |row, index|
#      cells = row.cells.map { |c| c.text.strip }
#
#      next if cells.empty? || cells.all?(&:empty?) || cells[0] == "Групи"
#
#      group = cells[0]
#
#      if cells.length == 2 || cells[1..].all?(&:empty?)
#        result << { group: group, info: cells[1] || "—" }
#      else
#        result << { group: group, pairs: cells[1..] }
#      end
#    end
#
#    File.write('storage/changes.json', JSON.pretty_generate(result))
#  end
#
#  def send_changes(chat_id, user_id)
#    user = User.find_by(telegram_id: user_id)
#    unless user&.group_id
#      @bot.api.send_message(chat_id: chat_id, text: "Не вказана група користувача.")
#      return
#    end
#
#    group = Group.find_by(id: user.group_id)
#    unless group
#      @bot.api.send_message(chat_id: chat_id, text: "Групу не знайдено.")
#      return
#    end
#
#    json_path = File.join('storage', 'changes.json')
#    unless File.exist?(json_path)
#      @bot.api.send_message(chat_id: chat_id, text: "Файл зі змінами не знайдено.")
#      return
#    end
#
#    changes = JSON.parse(File.read(json_path))
#    group_changes = changes.find { |c| c["group"] == group.group_name }
#
#    unless group_changes
#      @bot.api.send_message(chat_id: chat_id, text: "Змін для групи #{group.group_name} не знайдено.")
#      return
#    end
#
#    if group_changes["info"]
#      text = "Зміни для групи #{group.group_name}: #{group_changes["info"]}"
#    else
#      text = "Зміни для групи #{group.group_name}:\n"
#      group_changes["pairs"].each_with_index do |item, i|
#        text << "  #{i + 1} пара: #{item.empty? ? '—' : item}\n"
#      end
#    end
#
#    @bot.api.send_message(chat_id: chat_id, text: text)
#  end
#end
