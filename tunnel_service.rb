#!/usr/bin/env ruby

require 'socket'
require 'net/http'
require 'uri'
require 'json'

puts "==================================="
puts "Онлайн тунелі для Ruby Blog"
puts "==================================="
puts "Це створить публічну адресу для вашого сайту"
puts "==================================="

# Отримання локальної IP-адреси
def get_local_ip
  Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address
rescue
  "localhost"
end

local_ip = get_local_ip
local_port = 4567

puts "Локальний сервер: http://#{local_ip}:#{local_port}"
puts

puts "🌐 Варіанти обходу брандмауера:"
puts "==================================="
puts

puts "1. ngrok (найпростіший):"
puts "   a) Завантажте: https://ngrok.com/download"
puts "   b) Розпакуйте та запустіть: ngrok http 4567"
puts "   c) Отримайте публічну адресу"
puts "   d) На телефоні відкривайте: https://xxxx.ngrok.io"
puts

puts "2. localtunnel:"
puts "   a) npm install -g localtunnel"
puts "   b) lt --port 4567"
puts "   c) Отримайте публічну адресу"
puts

puts "3. serveo:"
puts "   a) ssh -R 80:localhost:4567 serveo.net"
puts "   b) Отримайте публічну адресу"
puts

puts "4. cloudflared:"
puts "   a) Завантажте з https://github.com/cloudflare/cloudflared"
puts "   b) cloudflared tunnel --url http://localhost:4567"
puts

puts "==================================="
puts "Рекомендую ngrok - найнадійніший варіант"
puts "==================================="

# Спроба автоматично перевірити ngrok
begin
  ngrok_running = system('tasklist | findstr ngrok >nul 2>&1')
  if ngrok_running
    puts "✅ ngrok вже запущено!"
    puts "Перевірте http://127.0.0.1:4040 для отримання адреси"
  else
    puts "💡 Запустіть ngrok для миттєвого доступу"
  end
rescue
  puts "💡 Встановіть ngrok для простого доступу"
end

puts
puts "Після запуску тунелю ви отримаєте адресу типу:"
puts "https://random-words.ngrok.io"
puts "Ця адреса буде доступна звідусіль!"
