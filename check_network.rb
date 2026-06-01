#!/usr/bin/env ruby

require 'socket'
require 'net/http'
require 'timeout'

puts "==================================="
puts "Перевірка мережі для Ruby Blog"
puts "==================================="

# Отримання всіх IP-адрес
def get_all_ips
  Socket.ip_address_list.select { |addr| addr.ipv4? && !addr.ipv4_loopback? }.map(&:ip_address)
end

# Перевірка чи сервер працює на конкретній IP
def server_running_on_ip?(ip, port, timeout = 2)
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

# Перевірка чи сервер слухає на всіх інтерфейсах
def check_server_listening(port)
  puts "Перевірка чи сервер слухає на порту #{port}..."
  
  # Перевіряємо localhost
  if server_running_on_ip?('127.0.0.1', port)
    puts "✅ Сервер працює на localhost:#{port}"
  else
    puts "❌ Сервер не працює на localhost:#{port}"
    return false
  end
  
  # Перевіряємо всі IP-адреси
  ips = get_all_ips
  working_ips = []
  
  ips.each do |ip|
    if server_running_on_ip?(ip, port)
      puts "✅ Сервер доступний на #{ip}:#{port}"
      working_ips << ip
    else
      puts "❌ Сервер недоступний на #{ip}:#{port}"
    end
  end
  
  return working_ips
end

# Перевірка брандмауера
def check_firewall
  puts "\nПеревірка брандмауера Windows..."
  
  # Перевіряємо чи брандмауер блокує
  begin
    result = `netsh advfirewall show currentprofile`
    if result.include?('State                                 ON')
      puts "⚠️  Брандмауер Windows увімкнений"
      puts "💡 Може блокувати з'єднання"
      return true
    else
      puts "✅ Брандмауер Windows вимкнений"
      return false
    end
  rescue
    puts "❌ Не вдалося перевірити брандмауер"
    return nil
  end
end

# Основна перевірка
port = 4567
working_ips = check_server_listening(port)
firewall_on = check_firewall

puts "\n==================================="
puts "Результати перевірки:"
puts "==================================="

if working_ips.nil? || working_ips.empty?
  puts "❌ Сервер не доступний жодній IP-адресі"
  puts "💡 Рішення:"
  puts "   1. Переконайтеся, що сервер запущено: ruby app.rb"
  puts "   2. Перевірте чи додано set :bind, '0.0.0.0'"
  puts "   3. Спробуйте інший порт"
else
  puts "✅ Сервер доступний на IP-адресах:"
  working_ips.each { |ip| puts "   http://#{ip}:#{port}" }
  
  if firewall_on
    puts "\n⚠️  Брандмауер може блокувати з'єднання"
    puts "💡 Рішення:"
    puts "   1. Запустіть: ruby fix_firewall.ps1 (від адміністратора)"
    puts "   2. Або тимчасово вимкніть брандмауер"
  end
end

puts "\n==================================="
puts "Інструкції для телефону:"
puts "==================================="
puts "1. Переконайтеся, що телефон і ПК в одній Wi-Fi мережі"
puts "2. Спробуйте ці адреси по черзі:"
get_all_ips.each { |ip| puts "   http://#{ip}:#{port}" }
puts "3. Якщо не працює, перевірте брандмауер ПК"
puts "4. Перевірте чи телефон не блокує локальні мережі"
