#!/usr/bin/env ruby

require 'socket'
require 'timeout'

puts "==================================="
puts "Тестування з'єднання для Ruby Blog"
puts "==================================="

# Отримання IP-адрес
def get_local_ips
  Socket.ip_address_list.select { |addr| addr.ipv4? && !addr.ipv4_loopback? }.map(&:ip_address)
end

# Тестування порту
def test_port(ip, port, timeout = 3)
  begin
    Timeout::timeout(timeout) do
      Socket.tcp(ip, port, connect_timeout: timeout).close
      return true
    end
  rescue
    return false
  end
end

ips = get_local_ips
port = 4567

puts "Знайдено IP-адреси:"
ips.each { |ip| puts "  - #{ip}" }
puts

puts "Тестування портів:"
puts "==================================="

# Тестування кожної IP-адреси
ips.each do |ip|
  # Тест з'єднання
  server_status = test_port(ip, port) ? "✅ Доступний" : "❌ Недоступний"
  
  puts "#{ip}:#{port} - #{server_status}"
  
  # Якщо недоступний, пропонуємо рішення
  unless test_port(ip, port)
    puts "   💡 Рішення: запустіть fix_firewall.ps1 від імені адміністратора"
  end
end

puts
puts "==================================="
puts "Інструкції:"
puts "==================================="
puts "1. Клікніть правою кнопкою на fix_firewall.ps1"
puts "2. Виберіть 'Запустити від імені адміністратора'"
puts "3. Натисніть 'Так' у вікні безпеки"
puts "4. Після налаштування запустіть сервер:"
puts "   ruby start_server.rb"
puts "5. На телефоні відкрийте одну з адрес:"
ips.each { |ip| puts "   http://#{ip}:#{port}" }
puts
puts "==================================="
