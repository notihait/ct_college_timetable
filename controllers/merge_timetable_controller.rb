class MergeTimetableController
  # Ініціалізуємо з основним розкладом і змінами (хеші або масив)
  def initialize(main_schedule, changes_schedule)
    @main_schedule = deep_dup(main_schedule)
    @changes_schedule = changes_schedule[:groups]
    @day_of_the_week = changes_schedule[:day_of_the_week]
    end

  # Головний метод, який робить злиття та повертає результат
  
  def merge
  changes_hash = if @changes_schedule.is_a?(Array)
                   @changes_schedule.each_with_object({}) do |entry, h|
                     group_name = entry['group'] || entry['name'] || entry.keys.first
                     h[group_name] = entry
                   end
                 else
                   @changes_schedule
                 end

  changes_hash.each do |group, changes_data|
    next unless @main_schedule.key?(group)

    if changes_data.is_a?(Array)
      # Масив замін (наприклад: ["ДПА", "ДПА", ...])
      main_days = @main_schedule[group]['days']
      next if main_days.nil? || main_days.empty?

      # Проходимо по кожному дню (можна змінити на перший день, якщо потрібно)
      main_day = main_days[@day_of_the_week]
      lessons = main_day['lessons']
      next unless lessons
    
      lessons.each_with_index do |lesson, idx|
        next unless changes_data[idx]
  
        # Замінюємо всі предмети уроку на один предмет із changes_data
        lesson['subjects'].each do |subject|
        subject['subject'] = changes_data[idx]
        end
      end

    elsif changes_data.is_a?(Hash) && changes_data.key?('days')
      # Оригінальна логіка для складної структури
      changes_days = changes_data['days']
      changes_days.each do |change_day|
        day_name = change_day['name']
        main_day = @main_schedule[group]['days'].find { |d| d['name'] == day_name }
        next unless main_day

        change_day['lessons'].each do |change_lesson|
          lesson_num = change_lesson['lesson']
          main_lesson = main_day['lessons'].find { |l| l['lesson'] == lesson_num }
          next unless main_lesson

          change_lesson['subjects'].each_with_index do |change_subject, idx|
            if ['', '-'].include?(change_subject['subject'])
              next
            else
              if main_lesson['subjects'][idx]
                main_lesson['subjects'][idx] = change_subject
              else
                main_lesson['subjects'] << change_subject
              end
            end
          end
        end
      end
    else
      # Формат незрозумілий — пропускаємо
      next
    end
  end

  @main_schedule
end





  private

  # Глибоке копіювання хешу (щоб не мутувати вхідні дані)
  def deep_dup(obj)
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), h|
        h[k] = deep_dup(v)
      end
    when Array
      obj.map { |e| deep_dup(e) }
    else
      obj
    end
  end
end
