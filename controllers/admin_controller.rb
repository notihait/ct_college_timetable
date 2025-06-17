class AdminController
    def initialize(bot)
      @bot = bot
    end
  
    def start_group_creation(message)
      user = User.find_by(telegram_id: message.from.id)
      return unless user
  
       puts "User #{user.telegram_id} set state to awaiting_group_name"
      user.update(state: 'awaiting_group_name')
       puts "State set to 'awaiting_group_name' for user #{user.telegram_id}"
      @bot.api.send_message(chat_id: message.chat.id, text: "Введіть назву нової групи:")
    end
  
    def handle_group_creation(message)
        user = User.find_by(telegram_id: message.from.id)
        return unless user
      
        group_name = message.text.strip  
      
        if group_name.empty?
          @bot.api.send_message(chat_id: message.chat.id, text: "Назва групи не може бути пустою.")
          return
        end
      
        if Group.exists?(group_name: group_name)
          @bot.api.send_message(chat_id: message.chat.id, text: "Група вже існує.")
        else
          Group.create(group_name: group_name)
          @bot.api.send_message(chat_id: message.chat.id, text: "Група '#{group_name}' додана")
        end
      
        user.update(state: nil)
      end
      
  
    def list_groups(message)
      groups = Group.all
      if groups.any?
        list = groups.map.with_index(1) { |g, i| "#{i}. #{g.group_name}" }.join("\n")
        text = "Список груп:\n" + list
      else
        text = "Поки ще не має жодної групи."
      end
      @bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end
  