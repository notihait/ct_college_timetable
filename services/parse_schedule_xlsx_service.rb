require 'pry'
require 'creek'
require 'json'

class ParseScheduleXlsxService
  def call
    parse_schedule
  end

  def initialize(path)
    @path = path
  end

  def extract_subjects_and_teachers(cell_values)
    subjects = []
    current_subject = nil
    cell_values.delete("9:00 хвилина мовчання")
    
    cell_values.each_slice(2).each do |subj|
      subjects << { subject: subj.first, teacher: subj.last }
    end
    
    subjects
  end

  def creek 
    @creek ||= Creek::Book.new(@path)
  end
  
  def sheet
    @sheet ||= creek.sheets.first.rows.to_a.map(&:values)
  end

  def days_rows 
    @days_rows = sheet.each_with_index.select do |row, i|
      row.first && i >= 2
    end.map { |row, i| i }
  end

  def groups
    return @groups unless @groups.nil?

    @groups = {}
    sheet[1].each_with_index do |col_name, col_idx|
      next unless col_name
      
      @groups[col_name] = {
        column: col_idx,
        days: []
      }
    end

    @groups
  end

  #перебираем наши дни как диапазоны строк, в массиве номер строки с которой начинается день
  def  parse_schedule
    days_rows.each_with_index do |day_row_idx, day_num|
      # Перваый стрлбец первой страки дня недели содержт его название 
      day_name = sheet[day_row_idx].first
      
      # Подтягиваем начало следующего дня - нам понадобятся диапазоны  
      next_day_row_idx = days_rows[day_num + 1] || sheet.size
      
      groups.each do |group_name, group_data|
        col_idx = group_data[:column]
        
        # Collect all non-empty cells from day name row to next day (excluding next day row)
        lesson = nil
        subjects_by_lesson = (day_row_idx...next_day_row_idx).each_with_object({}) do |row_idx, hash|
          # Get lesson number from column 2 (index 1)
          lesson = sheet[row_idx][2] unless sheet[row_idx][2].nil?
          
          subject = sheet[row_idx][col_idx]
          next unless subject && !subject.to_s.strip.empty?
          
          hash[lesson] ||= []
          hash[lesson] << subject
        end
        
        processed_days = []
        subjects_by_lesson.each do |lesson, subjects|
          subject_teacher_pairs = extract_subjects_and_teachers(subjects)
          subject_teacher_pairs.reject! { |st| st[:subject].nil? || st[:subject].empty? }
          next if subject_teacher_pairs.empty?

          processed_days << { lesson: lesson, subjects: subject_teacher_pairs }
        end
        
        group_data[:days] << { name: day_name, lessons: processed_days }
      end
    end
    groups
  end
end





