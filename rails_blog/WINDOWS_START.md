# Запуск Rails-версії на Windows

1. Відкрий термінал у папці `rails_blog`.
2. Виконай:

```bash
bundle install
ruby bin/rails server
```

3. Відкрий у браузері:

```text
http://localhost:3000
```

Якщо Windows відкриває вікно вибору програми для `bin/rails`, не вибирай програму. Запускай саме так:

```bash
ruby bin/rails server
```

У цьому архіві в `Gemfile` додано `tzinfo-data`, бо на Windows Rails не знаходить системну базу часових поясів без цього gem.

## Додаткове виправлення Sprockets

Додано файл `app/assets/config/manifest.js`, який потрібен Rails/Sprockets для підключення CSS.
