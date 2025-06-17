require 'docx'

class ParseScheduleChangesService
  DAYS_OF_THE_WEEK = [
    'Понеділок',
    'Вівторок',
    'Середа',
    'Четвер',
    'П’ятниця'
  ]

  def initialize(file_path)
    @file_path = file_path
  end

  def call
    parse
  end

  private

  def day_of_the_week
    @day_of_the_week ||= DAYS_OF_THE_WEEK.find_index { |day| docx.text.include?(day.downcase) }
  end

  def docx
    @docx ||= Docx::Document.open(@file_path)
  end

  def table
    @table ||= docx.tables.first
  end

  def parse
    group = nil

    groups = table.rows[1..].each_with_object({}) do |row, result_hash|
      if row.cells[0].text.strip != ''
        group = row.cells[0].text.strip
        result_hash[group] ||= Array.new(6, '')
      end

      last_not_empty_value = ''

      (1..6).each do |i|
        cell = row.cells[i]

        last_not_empty_value = cell.text unless cell.nil?

        result_hash[group][i - 1] = [
          result_hash[group][i - 1],
          last_not_empty_value
        ].reject(&:empty?).join(' | ')
      end
    end
    { groups: groups, day_of_the_week: day_of_the_week }
  end
end

# ParseScheduleChangesService.new('file.docx').call
