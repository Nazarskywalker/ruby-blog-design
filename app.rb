require 'sinatra'
require 'erb'
require 'fileutils'
require 'json'

# Налаштування для доступу з інших пристроїв та завантаження файлів
configure do
  set :bind, '0.0.0.0'  # Дозволяє доступ з будь-якої IP-адреси
  set :port, 4567       # Порт сервера
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :uploads_dir, File.join(settings.public_folder, 'uploads')
  FileUtils.mkdir_p(settings.uploads_dir) unless Dir.exist?(settings.uploads_dir)
  
  # Вимикаємо кешування для оновлень в реальному часі
  set :static_cache_control, [:no_cache, :must_revalidate]
  
  # Налаштування для стабільної роботи
  set :server_settings, {
    timeout: 60,
    verbose: false
  }
end

# Обробка помилок
error do
  "Помилка сервера: #{env['sinatra.error'].message}"
end

# Логування запитів для діагностики
before do
  puts "[#{Time.now.strftime('%H:%M:%S')}] #{request.request_method} #{request.path_info}"
end

# Массив для зберігання постів (у пам'яті)
posts = []
post_id_counter = 1

# Час останнього оновлення для real-time синхронізації
last_update_time = Time.now.to_f

# Головна сторінка - список всіх постів
get '/' do
  erb :index, locals: { posts: posts }
end

# Сторінка управління постами
get '/posts/manage' do
  erb :manage_posts, locals: { posts: posts }
end

# Сторінка створення/редагування поста
get '/posts/new' do
  erb :new_post, locals: { post: nil, action: '/posts' }
end

# Сторінка редагування існуючого поста
get '/posts/:id/edit' do
  post = posts.find { |p| p[:id] == params[:id].to_i }
  if post
    erb :new_post, locals: { post: post, action: "/posts/#{post[:id]}" }
  else
    redirect '/'
  end
end

# Створення нового поста
post '/posts' do
  title = params[:title]
  content = params[:content]
  image = params[:image]
  
  image_path = nil
  if image && image[:tempfile]
    filename = "post_#{post_id_counter}_#{Time.now.to_i}_#{image[:filename]}"
    image_path = File.join(settings.uploads_dir, filename)
    File.open(image_path, 'wb') { |f| f.write(image[:tempfile].read) }
    image_path = "/uploads/#{filename}"
  end
  
  if title && !title.empty? && content && !content.empty?
    new_post = {
      id: post_id_counter,
      title: title,
      content: content,
      image: image_path,
      created_at: Time.now.strftime("%Y-%m-%d %H:%M")
    }
    posts << new_post
    post_id_counter += 1
    # Оновлюємо час останньої зміни
    $last_update_time = Time.now.to_f
  end
  
  redirect '/'
end

# Оновлення поста
put '/posts/:id' do
  post = posts.find { |p| p[:id] == params[:id].to_i }
  if post
    post[:title] = params[:title] if params[:title] && !params[:title].empty?
    post[:content] = params[:content] if params[:content] && !params[:content].empty?
    
    # Обробка нового зображення
    image = params[:image]
    if image && image[:tempfile]
      filename = "post_#{post[:id]}_#{Time.now.to_i}_#{image[:filename]}"
      image_path = File.join(settings.uploads_dir, filename)
      File.open(image_path, 'wb') { |f| f.write(image[:tempfile].read) }
      post[:image] = "/uploads/#{filename}"
    end
    
    post[:updated_at] = Time.now.strftime("%Y-%m-%d %H:%M")
    # Оновлюємо час останньої зміни
    $last_update_time = Time.now.to_f
  end
  redirect '/'
end

# Видалення поста
delete '/posts/:id' do
  posts.delete_if { |p| p[:id] == params[:id].to_i }
  # Оновлюємо час останньої зміни
  $last_update_time = Time.now.to_f
  redirect '/'
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

# Перегляд окремого поста
get '/posts/:id' do
  post = posts.find { |p| p[:id] == params[:id].to_i }
  if post
    erb :show_post, locals: { post: post }
  else
    redirect '/'
  end
end
