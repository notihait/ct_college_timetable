require 'date'
require 'json'

class DayOfWeekController
  WEEK_DAYS = {
    1 => 'Понеділок',
    2 => 'Вівторок',
    3 => 'Середа',
    4 => 'Четвер',
    5 => "П'ятниця"
  }

  def initialize(timetable_path = './storage/merged_schedule.json')
    @timetable_path = timetable_path
  end

  def get_schedule_for_day(day_number, group_name)
    data = JSON.parse(File.read(@timetable_path))
    day_name = WEEK_DAYS[day_number % 7]

    group_schedule = data[group_name]
    return "Розклад для групи #{group_name} не знайдено." unless group_schedule

    day_schedule = group_schedule['days'].find { |day| day['name'] == day_name }
    return "На #{day_name} занять немає." unless day_schedule

    message = "#{day_name}, #{group_name}:\n"
    day_schedule['lessons'].each do |lesson|
      lesson_number = lesson['lesson']
      lesson['subjects'].each do |subject|
        message += "Пара #{lesson_number}: #{subject['subject']} (#{subject['teacher']})\n"
      end
    end

    message
  end
end
