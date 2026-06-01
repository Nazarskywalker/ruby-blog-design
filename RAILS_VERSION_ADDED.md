# Додано Ruby on Rails реалізацію

У проєкт додано папку `rails_blog/` — це окрема Ruby on Rails версія блогу.

Головна сторінка блогу реалізована тут:

- `rails_blog/app/views/posts/index.html.erb`

Основні Rails-файли:

- `rails_blog/config/routes.rb`
- `rails_blog/app/controllers/posts_controller.rb`
- `rails_blog/app/views/layouts/application.html.erb`
- `rails_blog/app/assets/stylesheets/application.css`

Запуск:

```bash
cd rails_blog
bundle install
bin/rails server
```
