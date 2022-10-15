# Gitlab Runner Install Role
## Что делает Role
1. Загрузка скрипта для установки репозитория `Gitlab`.
2. Установка репозитория `Gitlab`.
3. Установка `GitLab Runner`.
4. Регистрация `GitLab Runner`.
5. Предоставляем разрешение для `GitLab Runner`.
6. Запуск `GitLab Runner`.

## Переменные

| Название переменной | Значение | Описание |
| :--- | :--- | :--- |
| `reg_runner_token` | `GR1348941zhxmNwD8zrzySqCyJtM3` | Токен для GitLab Runner |
| `gitlab_runner_script_url` | `https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh` | Установочный скрипт репозитория GitLab Runner  |
| `gitlab_runner_url` | `http://gitlab` | URL Gitlab |
| `gitlab_runner_executor` | `shell` | Режим executor для GitLab Runner |