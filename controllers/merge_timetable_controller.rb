#require 'json'
#
#def merge_timetable_with_changes(timetable_path, changes_path, output_path)
#  timetable = JSON.parse(File.read(timetable_path))
#  changes = JSON.parse(File.read(changes_path))
#
#  day_name = "П'ятниця"  
#
#  changes.each do |change|
#    group_name = change["group"]
#    next unless timetable[group_name]
#
#    group_schedule = timetable[group_name]
#    day = group_schedule["days"].find { |d| d["name"] == day_name }
#    day ||= { "name" => day_name, "lessons" => [] }
#
#    lessons_hash = day["lessons"].map { |l| [l["lesson"], l] }.to_h
#
#    if change["pairs"]
#      change["pairs"].each_with_index do |pair, index|
#        lesson_number = (index + 1).to_s
#
#        next if pair == "-" || pair.strip.empty?
#
#        if pair == "" || pair == "✔" || pair == "✓"
#          next
#        else
#          lessons_hash[lesson_number] = {
#            "lesson" => lesson_number,
#            "subjects" => [
#              {
#                "subject" => pair,
#                "teacher" => "Замінено"
#              }
#            ]
#          }
#        end
#      end
#    elsif change["info"]
#      day["lessons"] = [
#        {
#          "lesson" => "1",
#          "subjects" => [
#            {
#              "subject" => change["info"],
#              "teacher" => change["info"]
#            }
#          ]
#        }
#      ]
#    end
#
#    group_schedule["days"].reject! { |d| d["name"] == day_name }
#    group_schedule["days"] << { "name" => day_name, "lessons" => lessons_hash.values.sort_by { |l| l["lesson"].to_i } }
#  end
#
#  File.write(output_path, JSON.pretty_generate(timetable))
#  puts "✅ Зміни застосовано і збережено до #{output_path}"
#end