# OpenCode Railway Deployment

OpenCode Web UI с Volume для persistence.

## Структура

- `/data/projects` — рабочие проекты (сохраняются в Volume)
- `/data/.config/opencode` — конфигурация OpenCode (сохраняется в Volume)

## Переменные окружения

- `OPENCODE_SERVER_PASSWORD` — пароль для доступа (опционально)
- `OPENCODE_GO_API_KEY` — API ключ для OpenCode Go провайдера

## Деплой

1. Подключи репозиторий к Railway
2. Добавь переменные окружения
3. Volume `/data` создастся автоматически

## Доступ

После деплоя открой публичный URL — это Web UI OpenCode.
