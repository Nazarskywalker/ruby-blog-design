#!/usr/bin/env ruby

# Простий скрипт для зміни порту в app.rb

puts "==================================="
puts "Зміна порту для Ruby Blog"
puts "==================================="

# Читаємо поточний файл
content = File.read('app.rb')

# Замінюємо порт 4567 на 3000
if content.include?('set :port, 4567')
  content.gsub!('set :port, 4567', 'set :port, 3000')
  File.write('app.rb', content)
  puts "✅ Порт змінено на 3000"
else
  puts "❌ Не знайдено налаштування порту"
end

puts "==================================="
puts "Тепер запустіть:"
puts "ruby app.rb"
puts "==================================="
