require 'json'

class ScheduleFormatter
  def self.load_schedule(path = 'data/schedule.json')
    file = File.read(path)
    JSON.parse(file)
  end

  def self.format_for_group(schedule, group_name)
    group = schedule[group_name]
    return "Розклад для групи #{group_name} не знайдено." unless group

    result = ["📅 *Розклад для групи #{group_name}*"]

    group['days'].each do |day|
      result << "\n*#{day['name']}*"
      day['lessons'].each do |lesson|
        lesson_number = lesson['lesson']
        subjects_text = lesson['subjects'].map do |subj|
          "— #{subj['subject']} (#{subj['teacher']})"
        end.join("\n")

        result << "*#{lesson_number}.*\n#{subjects_text}"
      end
    end

    result.join("\n\n")
  end
end
