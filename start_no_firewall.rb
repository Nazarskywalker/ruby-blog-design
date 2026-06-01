#!/usr/bin/env ruby

require 'socket'

# Отримання локальної IP-адреси
def get_local_ip
  Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address
rescue
  "localhost"
end

# Спосіб 1: Інший порт (менш блокований)
port = 3000
local_ip = get_local_ip

puts "==================================="
puts "Ruby Blog (обхід брандмауера)"
puts "==================================="
puts "Порт: #{port} (менш блокований)"
puts "Локальний доступ: http://localhost:#{port}"
puts "Мережевий доступ: http://#{local_ip}:#{port}"
puts "==================================="
puts "На телефоні спробуйте:"
puts "http://#{local_ip}:#{port}"
puts "==================================="

puts "Запускаємо сервер на порту #{port}..."

# Запускаємо основний додаток з іншим портом
system("ruby -e \"require 'sinatra'; set :bind, '0.0.0.0'; set :port, #{port}; require_relative 'app.rb'\"")
