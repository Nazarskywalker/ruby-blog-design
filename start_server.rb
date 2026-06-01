#!/usr/bin/env ruby

require 'socket'
require 'sinatra/base'

# Отримання локальної IP-адреси
def get_local_ip
  Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address
rescue
  "localhost"
end

local_ip = get_local_ip
port = 4567

puts "==================================="
puts "Ruby Blog запускається..."
puts "==================================="
puts "Локальний доступ: http://localhost:#{port}"
puts "Мережевий доступ: http://#{local_ip}:#{port}"
puts "==================================="
puts "Для доступу з телефону:"
puts "1. Переконайтеся, що телефон і ПК в одній мережі Wi-Fi"
puts "2. Відкрийте браузер на телефоні"
puts "3. Введіть: http://#{local_ip}:#{port}"
puts "==================================="
puts "Для зупинки сервера натисніть Ctrl+C"
puts "==================================="

# Обробка сигналів для коректного завершення
trap('INT') do
  puts "\nСервер зупиняється..."
  exit 0
end

trap('TERM') do
  puts "\nСервер зупиняється..."
  exit 0
end

# Перевірка доступності порту
def check_port_available(ip, port)
  require 'socket'
  begin
    server = TCPServer.new(ip, port)
    server.close
    true
  rescue
    false
  end
end

# Перевірка чи порт вільний
unless check_port_available('0.0.0.0', port)
  puts "⚠️  Порт #{port} вже використовується!"
  puts "Спробуйте інший порт: ruby start_server.rb --port 3000"
  exit 1
end

# Запуск Sinatra сервера з кращою конфігурацією
class BlogApp < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, port
  set :server, 'puma'
  set :environment, :development
  
  # Налаштування Puma для стабільності
  set :server_settings, {
    Host: '0.0.0.0',
    Port: port,
    Threads: '0:4',
    workers: 0,
    daemon: false
  }
  
  # Вимикаємо автоматичне перезавантаження
  set :reload, false
  
  # Обробка помилок
  error do
    "Помилка: #{env['sinatra.error'].message}"
  end
  
  # Запуск додатку
  run! if app_file == $0
end

# Завантажуємо основний додаток
require_relative 'app.rb'
