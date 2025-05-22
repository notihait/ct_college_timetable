module Core
  module Keyboards
    def self.group_selection_keyboard(groups)
      Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: groups.map do |group|
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(
              text: group.group_name,
              callback_data: "group_#{group.id}"
            )
          ]
        end
      )
    end
    
    
  end
end
