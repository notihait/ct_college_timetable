module Core
  module Keyboards
    class << self
      def group_selection_keyboard(groups)

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

      def user_main_menu_keyboard(is_admin: false)
        keyboard_buttons = [
          [Telegram::Bot::Types::KeyboardButton.new(text: "Обрати групу")],
          [
            Telegram::Bot::Types::KeyboardButton.new(text: "Мій розклад"),
            Telegram::Bot::Types::KeyboardButton.new(text: "Хто я?")
          ]
        ]
      
        if is_admin
          keyboard_buttons << [Telegram::Bot::Types::KeyboardButton.new(text: "Адмін-панель")]
        end
      
        Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: keyboard_buttons,
          resize_keyboard: true
        )
      end
      
      

      def admin_menu_keyboard
        Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: [
            [{ text: 'Список груп' }, { text: 'Додати групу' }],
            [{ text: 'Імпорт груп з таблиці' }], [{ text: 'Оновити розклад' }],
            [{ text: 'Додати заміни' }], [{ text: 'Назад' }]
          ],
          one_time_keyboard: true
        )
      end

      def days_keyboard
          buttons = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Понеділок', callback_data: 'day_1'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Вівторок', callback_data: 'day_2'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Середа', callback_data: 'day_3'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Четвер', callback_data: 'day_4'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: "П'ятниця", callback_data: 'day_5'),
          ]

          Telegram::Bot::Types::InlineKeyboardMarkup.new(
            inline_keyboard: buttons.each_slice(3).to_a
          )
      end
    end
  end
end
