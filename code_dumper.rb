require 'find'

output_file = 'code_dump.txt'

File.open(output_file, 'w') do |output|
  Find.find('.') do |path|
    next if File.directory?(path) || path == output_file
    
    relative_path = path.gsub(/^\.\//, '')
    
    begin
      content = File.read(path)
      output.puts "/#{relative_path}"
      output.puts content
      output.puts
    rescue => e
      puts "Ошибка при чтении файла #{path}: #{e.message}"
    end
  end
end

puts "Готово! Результат сохранён в #{output_file}"