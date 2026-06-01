#!/usr/bin/env ruby

require 'socket'

# Отримання IP-адреси
def get_local_ips
  Socket.ip_address_list.select { |addr| addr.ipv4? && !addr.ipv4_loopback? }.map(&:ip_address)
end

# Знаходимо робочу IP (192.168.50.86)
working_ip = "192.168.50.86"
port = 8080

puts "==================================="
puts "ЗАПУСК РУБІ-БЛОГУ НА РОБОЧОМУ IP"
puts "==================================="
puts "Робочий IP: #{working_ip}"
puts "Порт: #{port}"
puts "Локальний доступ: http://localhost:#{port}"
puts "Мережевий доступ: http://#{working_ip}:#{port}"
puts "==================================="
puts "НА ТЕЛЕФОНІ ВІДКРИВАЙТЕ:"
puts "http://#{working_ip}:#{port}"
puts "==================================="

# Створюємо конфігурацію для робочого IP
File.write('working_app.rb', <<~RUBY)
  require 'sinatra'
  require 'erb'
  require 'fileutils'
  
  # Налаштування для конкретного IP
  set :bind, '0.0.0.0'
  set :port, #{port}
  set :server, 'puma'
  set :environment, :development
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :uploads_dir, File.join(settings.public_folder, 'uploads')
  FileUtils.mkdir_p(settings.uploads_dir) unless Dir.exist?(settings.uploads_dir)
  
  # Вимикаємо кешування
  set :static_cache_control, [:no_cache, :must_revalidate]
  
  # Дані постів
  posts = []
  post_id_counter = 1
  
  # Час останнього оновлення для real-time синхронізації
  $last_update_time = Time.now.to_f
  
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
  
  # Редагування поста
  get '/posts/:id/edit' do
    post = posts.find { |p| p[:id] == params[:id].to_i }
    if post
      erb :new_post, locals: { post: post, action: "/posts/\#{post[:id]}" }
    else
      redirect '/'
    end
  end
  
  # Створення/оновлення поста
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
  
  # Оновлення поста
  put '/posts/:id' do
    post = posts.find { |p| p[:id] == params[:id].to_i }
    if post
      post[:title] = params[:title] if params[:title] && !params[:title].empty?
      post[:content] = params[:content] if params[:content] && !params[:content].empty?
      post[:updated_at] = Time.now.strftime("%Y-%m-%d %H:%M")
    end
    redirect '/'
  end
  
  # Видалення поста
  delete '/posts/:id' do
    posts.delete_if { |p| p[:id] == params[:id].to_i }
    redirect '/'
  end
  
  # Логування
  before do
    puts "[\#{Time.now.strftime('%H:%M:%S')}] \#{request.request_method} \#{request.path_info} from \#{request.ip}"
  end
  
  # API для перевірки оновлень в реальному часі
  get '/check-updates' do
    content_type :json
    {
      lastUpdate: $last_update_time || Time.now.to_f,
      postsCount: posts.length,
      timestamp: Time.now.to_f
    }.to_json
  end
RUBY

puts "Запускаємо повний Ruby Blog..."
puts "Сервер буде доступний за адресою:"
puts "http://#{working_ip}:#{port}"
puts

# Запускаємо сервер
exec("ruby working_app.rb")
