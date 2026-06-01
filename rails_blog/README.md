# Rails Blog

Це Ruby on Rails версія блогу для домашнього завдання.

## Що реалізовано

- головна сторінка блогу: `app/views/posts/index.html.erb`;
- маршрути Rails: `config/routes.rb`;
- контролер Rails: `app/controllers/posts_controller.rb`;
- layout: `app/views/layouts/application.html.erb`;
- стилі: `app/assets/stylesheets/application.css`;
- створення, редагування, видалення та перегляд постів;
- завантаження зображення для поста;
- AI-дизайн головної сторінки блогу.

## Як запустити

```bash
cd rails_blog
bundle install
bin/rails server
```

Після запуску відкрити:

```text
http://localhost:3000
```

> У цій навчальній версії пости зберігаються в пам'яті сервера, без бази даних.

## Виправлення для Windows RubyInstaller

У цій версії Rails змінено з `7.1` на `7.0.8`, а зайві залежності `importmap-rails`, `turbo-rails`, `stimulus-rails`, `jbuilder`, `debug` прибрано. Це потрібно, щоб `bundle install` не тягнув новий `psych 5.3.1`, який на твоєму Windows падає через `yaml.h not found` і пошкоджений MSYS2 keyring.

Якщо раніше вже запускав стару версію, краще видали папку `ruby-blog-ai-homepage-with-rails-fixed` і розпакуй цей архів заново.

Або в старій папці виконай:

```bash
cd rails_blog
bundle clean --force
bundle install
bin/rails server
```
