# OpenCode Railway Deployment

OpenCode Web UI с Volume для persistence.

## Настройка Volume (Обязательно!)

После первого деплоя:

1. Открой Railway Dashboard → твой проект
2. Перейди во вкладку **Volumes**
3. Нажми **New Volume**
4. **Mount Path**: `/data`
5. Перезадеплой сервис

## Структура данных

- `/data/projects` — рабочие проекты
- `/data/.config/opencode` — конфигурация OpenCode

## Переменные окружения

- `OPENCODE_SERVER_PASSWORD` — пароль для доступа
- `OPENCODE_GO_API_KEY` — API ключ OpenCode Go

## Доступ

Открой публичный URL после деплоя — это Web UI OpenCode.
