#!/usr/bin/env ruby

require 'socket'

# Отримання локальної IP-адреси
def get_local_ip
  Socket.ip_address_list.find { |addr| addr.ipv4_private? }.ip_address
rescue
  "localhost"
end

# Простий запуск на іншому порту
port = 3000
local_ip = get_local_ip

puts "==================================="
puts "Ruby Blog (простий запуск)"
puts "==================================="
puts "Порт: #{port}"
puts "Локальний доступ: http://localhost:#{port}"
puts "Мережевий доступ: http://#{local_ip}:#{port}"
puts "==================================="
puts "На телефоні спробуйте:"
puts "http://#{local_ip}:#{port}"
puts "==================================="

# Створюємо тимчасовий файл з налаштуванням
File.write('temp_app.rb', <<~RUBY)
  require 'sinatra'
  require 'erb'
  require 'fileutils'
  
  # Налаштування
  set :bind, '0.0.0.0'
  set :port, #{port}
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :uploads_dir, File.join(settings.public_folder, 'uploads')
  FileUtils.mkdir_p(settings.uploads_dir) unless Dir.exist?(settings.uploads_dir)
  
  # Дані постів
  posts = []
  post_id_counter = 1
  
  # Головна сторінка
  get '/' do
    erb :index, locals: { posts: posts }
  end
  
  # Управління постами
  get '/posts/manage' do
    erb :manage_posts, locals: { posts: posts }
  end
  
  # Створення поста
  get '/posts/new' do
    erb :new_post, locals: { post: nil, action: '/posts' }
  end
  
  # Перегляд поста
  get '/posts/:id' do
    post = posts.find { |p| p[:id] == params[:id].to_i }
    if post
      erb :show_post, locals: { post: post }
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
  
  # Завантаження шаблонів
  before do
    # Встановлюємо шлях до шаблонів
    set :views, File.dirname(__FILE__) + '/views'
  end
RUBY

# Запускаємо тимчасовий додаток
exec("ruby temp_app.rb")
