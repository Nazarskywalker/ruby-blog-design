#!/usr/bin/env ruby

require 'socket'

# Отримання локальної IP-адреси
def get_local_ip
  Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address
rescue
  "localhost"
end

# Порт 8080 - рідко блокується
port = 8080
local_ip = get_local_ip

puts "==================================="
puts "Ruby Blog (порт 8080)"
puts "==================================="
puts "Порт: #{port} (рідко блокується)"
puts "Локальний доступ: http://localhost:#{port}"
puts "Мережевий доступ: http://#{local_ip}:#{port}"
puts "==================================="
puts "На телефоні спробуйте:"
puts "http://#{local_ip}:#{port}"
puts "==================================="

# Створюємо тимчасовий файл з налаштуванням
File.write('temp_8080.rb', <<~RUBY)
  require 'sinatra'
  require 'erb'
  require 'fileutils'
  
  # Важливо - слухаємо на всіх інтерфейсах
  set :bind, '0.0.0.0'
  set :port, #{port}
  set :server, 'puma'
  set :environment, :development
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :uploads_dir, File.join(settings.public_folder, 'uploads')
  FileUtils.mkdir_p(settings.uploads_dir) unless Dir.exist?(settings.uploads_dir)
  
  # Дані постів
  posts = []
  post_id_counter = 1
  
  # Головна сторінка
  get '/' do
    erb File.read('views/index.erb'), locals: { posts: posts }
  end
  
  # Управління постами
  get '/posts/manage' do
    erb File.read('views/manage_posts.erb'), locals: { posts: posts }
  end
  
  # Створення поста
  get '/posts/new' do
    erb File.read('views/new_post.erb'), locals: { post: nil, action: '/posts' }
  end
  
  # Перегляд поста
  get '/posts/:id' do
    post = posts.find { |p| p[:id] == params[:id].to_i }
    if post
      erb File.read('views/show_post.erb'), locals: { post: post }
    else
      redirect '/'
    end
  end
  
  # Обробка форми створення поста
  post '/posts' do
    title = params[:title]
    content = params[:content]
    
    if title && !title.empty? && content && !content.empty?
      new_post = {
        id: post_id_counter,
        title: title,
        content: content,
        created_at: Time.now.strftime("%Y-%m-%d %H:%M")
      }
      posts << new_post
      post_id_counter += 1
    end
    
    redirect '/'
  end
  
  # Логування для діагностики
  before do
    puts "[\#{Time.now.strftime('%H:%M:%S')}] \#{request.request_method} \#{request.path_info} from \#{request.ip}"
  end
RUBY

puts "Запускаємо сервер на порту #{port}..."
puts "Натисніть Ctrl+C для зупинки"
puts

# Запускаємо тимчасовий додаток
exec("ruby temp_8080.rb")
