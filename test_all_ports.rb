#!/usr/bin/env ruby

require 'socket'
require 'timeout'

puts "==================================="
puts "Тестування всіх портів для Ruby Blog"
puts "==================================="

# Отримання IP-адрес
def get_local_ips
  Socket.ip_address_list.select { |addr| addr.ipv4? && !addr.ipv4_loopback? }.map(&:ip_address)
end

# Перевірка порту
def test_port(ip, port, timeout = 2)
  begin
    Timeout::timeout(timeout) do
      socket = Socket.tcp(ip, port)
      socket.close
      return true
    end
  rescue
    return false
  end
end

# Популярні порти для веб-серверів
ports = [3000, 4567, 8000, 8080, 8888, 9000]
ips = get_local_ips

puts "Знайдено IP-адреси:"
ips.each { |ip| puts "  - #{ip}" }
puts

puts "Тестування портів:"
puts "=================================="

working_combinations = []

ports.each do |port|
  puts "\nПорт #{port}:"
  
  # Перевіряємо localhost
  if test_port('127.0.0.1', port)
    puts "  ✅ localhost:#{port} - працює"
    
    # Перевіряємо всі IP-адреси
    ips.each do |ip|
      if test_port(ip, port)
        puts "  ✅ #{ip}:#{port} - працює"
        working_combinations << "#{ip}:#{port}"
      else
        puts "  ❌ #{ip}:#{port} - не працює"
      end
    end
  else
    puts "  ❌ localhost:#{port} - не працює"
  end
end

puts "\n==================================="
puts "Результати:"
puts "==================================="

if working_combinations.any?
  puts "✅ Робочі комбінації:"
  working_combinations.each { |combo| puts "  http://#{combo}" }
  
  puts "\n💡 Рекомендації:"
  puts "1. Запустіть сервер на одному з цих портів"
  puts "2. На телефоні спробуйте всі робочі адреси"
  puts "3. Порт 8080 зазвичай найкращий для мобільних"
else
  puts "❌ Жоден порт не працює"
  puts "\n💡 Рішення:"
  puts "1. Запустіть сервер: ruby start_8080.rb"
  puts "2. Перевірте брандмауер Windows"
  puts "3. Перевірте антивірус"
  puts "4. Переконайтеся, що телефон в тій же Wi-Fi мережі"
end

puts "\n==================================="
puts "Швидкий тест:"
puts "==================================="
puts "Спробуйте запустити:"
puts "ruby start_8080.rb"
puts "А потім на телефоні:"
ips.each { |ip| puts "http://#{ip}:8080" }
