#!/usr/bin/env ruby

require 'socket'

puts "==================================="
puts "Налаштування мережі для Ruby Blog"
puts "==================================="

# Отримання IP-адрес
def get_network_info
  info = {}
  
  # Локальна IP-адреса
  info[:local_ip] = Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address rescue "localhost"
  
  # Всі IPv4 адреси
  info[:all_ips] = Socket.ip_address_list.select { |addr| addr.ipv4? && !addr.ipv4_loopback? }.map(&:ip_address)
  
  return info
end

# Перевірка доступності порту
def port_open?(ip, port)
  begin
    Socket.tcp(ip, port, connect_timeout: 1).close
    true
  rescue
    false
  end
end

network_info = get_network_info
port = 4567

puts "Знайдено IP-адреси:"
network_info[:all_ips].each { |ip| puts "  - #{ip}" }
puts

puts "Основна IP-адреса для підключення: #{network_info[:local_ip]}"
puts "Порт: #{port}"
puts

puts "==================================="
puts "Інструкції для доступу з телефону:"
puts "==================================="
puts "1. Переконайтеся, що телефон і ПК в одній Wi-Fi мережі"
puts "2. Відкрийте на телефоні браузер"
puts "3. Введіть одну з адрес:"
network_info[:all_ips].each do |ip|
  puts "   http://#{ip}:#{port}"
end
puts

puts "==================================="
puts "Якщо не працює, спробуйте:"
puts "==================================="
puts "1. Тимчасово вимкніть брандмауер Windows:"
puts "   - Відкрийте 'Панель керування' -> 'Брандмауер Windows'"
puts "   - Натисніть 'Увімкнення або вимкнення брандмауера'"
puts "   - Вимкніть для поточної мережі"
puts
puts "2. Або виконайте в PowerShell (адміністратор):"
puts "   netsh advfirewall firewall add rule name=\"Ruby Blog\" dir=in action=allow protocol=TCP localport=4567"
puts
puts "3. Перевірте антивірус - він може блокувати підключення"
puts
puts "4. Спробуйте інший порт (наприклад 3000):"
puts "   ruby start_server.rb --port 3000"
puts

puts "==================================="
puts "Перевірка доступності портів..."
puts "==================================="

network_info[:all_ips].each do |ip|
  status = port_open?(ip, port) ? "✅ Доступний" : "❌ Заблоковано"
  puts "#{ip}:#{port} - #{status}"
end

puts
puts "Готово! Запускайте сервер: ruby start_server.rb"
