require 'json'


class GroupImportController
TIMETABLE_PATH = File.expand_path('../storage/timetable.json', __dir__)


  def import_groups
    json_data = File.read(TIMETABLE_PATH)
    timetable = JSON.parse(json_data)

    group_names = timetable.keys

    Group.delete_all

    group_names.each do |group_name|
      Group.create!(group_name: group_name)
    end

    group_names.size 
  rescue => e
    puts "Помилка під час імпорту груп: #{e.message}"
    0
  end
end
