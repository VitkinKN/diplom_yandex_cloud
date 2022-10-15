# WordPress Install Role
## Что делает Role
1. Установка `Nginx`.
2. Замена файла `Nginx` из шаблона.
3. Установка PHP зависимостей для `Wordpress`.
4. Создание директории для файлов `Wordpress`.
5. Загрузка последней версии `Wordpress`.
6. Установка прав на директорию.
7. Установка конфигурационного файла из шаблона.
8. Установка WP-CLI для `Wordpress`.

## Переменные

| Название переменной | Значение | Описание |
| :--- | :--- | :--- |
| `db_user` | `wordpress` | Пользователь для подключения к БД |
| `db_pass` | `wordpress` | Пароль от пользователя wordpress к БД  |
| `db_name` | `wordpress` | Имя БД для Wordpress |
| `db_host` | `db01` | Имя хоста БД |
| `owner` | `www-data` | Пользователь для директории сайта |
| `group` | `www-data` | Группа для директории сайта |
| `doc_root` | `/var/www/{{ virtual_domain }}` | Путь до директории сайта |
| `php_modules` | `shell` | Дополнительные модули PHP для установки |
| `wp_cli_phar_url` | `https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar` | Ссылка WP-CLI phar для загрузки |
| `wp_cli_bin_path` | `/usr/bin/{{ wp_cli_bin_command }}` | Директория назначения WP-CLI |
| `wp_cli_bin_command` | `wp` | Команда WP-CLI на хосте |
