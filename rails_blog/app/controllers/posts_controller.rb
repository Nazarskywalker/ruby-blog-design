class PostsController < ApplicationController
  protect_from_forgery with: :exception

  @@posts = []
  @@post_id_counter = 1
  @@last_update_time = Time.current.to_f

  def index
    @posts = @@posts
  end

  def manage
    @posts = @@posts
  end

  def show
    @post = find_post
    redirect_to root_path unless @post
  end

  def new
    @post = nil
    @action = posts_path
  end

  def edit
    @post = find_post
    if @post
      @action = post_path(@post[:id])
    else
      redirect_to root_path
    end
  end

  def create
    if post_params[:title].present? && post_params[:content].present?
      @@posts << {
        id: @@post_id_counter,
        title: post_params[:title],
        content: post_params[:content],
        image: save_uploaded_image(@@post_id_counter),
        created_at: Time.current.strftime("%Y-%m-%d %H:%M")
      }
      @@post_id_counter += 1
      touch_update_time
    end

    redirect_to root_path
  end

  def update
    post = find_post
    if post
      post[:title] = post_params[:title] if post_params[:title].present?
      post[:content] = post_params[:content] if post_params[:content].present?

      uploaded_image = save_uploaded_image(post[:id])
      post[:image] = uploaded_image if uploaded_image
      post[:updated_at] = Time.current.strftime("%Y-%m-%d %H:%M")
      touch_update_time
    end

    redirect_to root_path
  end

  def destroy
    @@posts.delete_if { |post| post[:id] == params[:id].to_i }
    touch_update_time
    redirect_to root_path
  end

  def check_updates
    render json: {
      lastUpdate: @@last_update_time,
      postsCount: @@posts.length,
      timestamp: Time.current.to_f
    }
  end

  private

  def post_params
    params.permit(:title, :content, :image)
  end

  def find_post
    @@posts.find { |post| post[:id] == params[:id].to_i }
  end

  def touch_update_time
    @@last_update_time = Time.current.to_f
  end

  def save_uploaded_image(post_id)
    uploaded_file = params[:image]
    return nil unless uploaded_file.respond_to?(:original_filename)

    uploads_dir = Rails.root.join("public", "uploads")
    FileUtils.mkdir_p(uploads_dir)

    safe_filename = uploaded_file.original_filename.gsub(/[^0-9A-Za-z.\-]/, "_")
    filename = "post_#{post_id}_#{Time.current.to_i}_#{safe_filename}"
    path = uploads_dir.join(filename)

    File.open(path, "wb") { |file| file.write(uploaded_file.read) }
    "/uploads/#{filename}"
  end
end
