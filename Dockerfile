# Используем официальный Ruby образ
FROM ruby:3.3

# Устанавливаем зависимости для SQLite (если используешь SQLite)
RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev

# Рабочая директория в контейнере
WORKDIR /app

# Копируем Gemfile и Gemfile.lock (если есть)
COPY Gemfile Gemfile.lock ./

# Устанавливаем гемы
RUN bundle install

# Копируем весь проект
COPY . .

# Устанавливаем переменные окружения (можно переопределять при запуске)
ENV TELEGRAM_TOKEN=your_token_here

# Команда для запуска бота
CMD ["ruby", "main.rb"]

