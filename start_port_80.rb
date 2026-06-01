#!/usr/bin/env ruby

require 'socket'
require 'sinatra/base'
require 'webrick'

# Отримання локальної IP-адреси
def get_local_ip
  Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address
rescue
  "localhost"
end

# Спосіб 3: Порт 80 (HTTP стандартний)
port = 80
local_ip = get_local_ip

puts "==================================="
puts "Ruby Blog (порт 80 - без брандмауера)"
puts "==================================="
puts "⚠️  Потрібні права адміністратора для порту 80"
puts "Порт: #{port} (стандартний HTTP)"
puts "Локальний доступ: http://localhost"
puts "Мережевий доступ: http://#{local_ip}"
puts "==================================="
puts "На телефоні просто:"
puts "http://#{local_ip}"
puts "==================================="

# Перевірка прав адміністратора для порту 80
begin
  require 'socket'
  server = TCPServer.new('0.0.0.0', port)
  server.close
rescue Errno::EACCES
  puts "❌ Потрібні права адміністратора!"
  puts "Запустіть цей файл від імені адміністратора"
  exit 1
end

class BlogApp < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, port
  set :server, 'webrick'
  set :environment, :development
  
  # Налаштування WEBrick для порту 80
  set :server_settings, {
    :BindAddress => '0.0.0.0',
    :Port => port,
    :Logger => WEBrick::Log.new('/dev/null'),
    :AccessLog => []
  }
  
  set :reload, false
  
  error do
    "Помилка: #{env['sinatra.error'].message}"
  end
  
  run! if app_file == $0
end

require_relative 'app.rb'
