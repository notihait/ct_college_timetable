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

    def self.user_main_menu_keyboard(is_admin: false)
      keyboard = [
        [{ text: 'Выбрать группу' }],
        [{ text: 'Мое расписание' }, { text: 'Хто я?' }]
      ]
      keyboard << [{ text: 'Админ-панель' }] if is_admin

      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: keyboard,
        resize_keyboard: true,
        one_time_keyboard: false
      )
    end

    def self.admin_menu_keyboard
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
  keyboard: [
    [
      Telegram::Bot::Types::KeyboardButton.new(text: 'Список групп'),
      Telegram::Bot::Types::KeyboardButton.new(text: 'Добавить группу')
    ],
    [
      Telegram::Bot::Types::KeyboardButton.new(text: 'Обновить расписание')
    ],
    [
      Telegram::Bot::Types::KeyboardButton.new(text: 'Назад')
    ]
  ],
  resize_keyboard: true,
  one_time_keyboard: true
)

    end
  end
end
