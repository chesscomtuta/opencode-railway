# OpenCode Railway Deployment 🚀

OpenCode (Crush) + Oh-My-OpenAgent с веб-доступом, развёрнутый на Railway.com

## 📋 Что включено

- **Crush** — AI coding agent от Charm Bracelet (преемник OpenCode)
- **Oh-My-OpenAgent** — мощный harness для параллельной работы агентов
- **Web Interface** — доступ через браузер без терминала
- **OpenCode Server** — полный HTTP API для программного доступа

## 🚀 Быстрый старт

### 1. Создай проект на Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/your-template-id)

Или вручную:
```bash
# Установи Railway CLI
npm install -g @railway/cli

# Залогинься
railway login

# Создай проект
railway init --name opencode-server
```

### 2. Добавь переменные окружения

Обязательные:
- `OPENCODE_GO_API_KEY` — твой API ключ от OpenCode Go ($10/месяц)

Опциональные:
- `OPENCODE_SERVER_PASSWORD` — пароль для защиты доступа
- `OPENCODE_SERVER_USERNAME` — имя пользователя (default: opencode)

### 3. Деплой

```bash
railway up
```

Или подключи GitHub репозиторий для авто-деплоя.

### 4. Доступ

После деплоя Railway даст публичный URL:
```
https://opencode-server-yourname.up.railway.app
```

Открой в браузере — это веб-интерфейс OpenCode!

## 🔧 API Endpoints

Сервер предоставляет OpenAPI 3.1 спецификацию:

```
GET /doc          # OpenAPI спецификация
GET /global/health # Health check
GET /session      # Список сессий
POST /session     # Создать сессию
GET /provider     # Список провайдеров
```

## 📝 Использование

### Web Interface
Просто открой URL в браузере — полноценный интерфейс для работы с AI агентом.

### API
```bash
curl -X POST https://your-app.railway.app/session \
  -H "Content-Type: application/json" \
  -u opencode:your-password \
  -d '{"title": "My Project"}'
```

### Подключение терминала
```bash
# Подключи локальный терминал к облачному серверу
opencode attach https://your-app.railway.app
```

## 🔌 Oh-My-OpenAgent Команды

После входа в веб-интерфейс доступны команды:

```
ultrawork (ulw)     # Запуск параллельных агентов
sisyphus            # Оркестратор агентов
hephaestus          # Код-агент
oracle              # Аналитический агент
librarian           # Документация
```

## 🛠️ Локальная разработка

```bash
# Клонируй
git clone https://github.com/yourusername/opencode-railway.git
cd opencode-railway

# Сборка
docker build -t opencode-railway .

# Запуск
docker run -p 3000:3000 \
  -e OPENCODE_GO_API_KEY=your_key \
  -e OPENCODE_SERVER_PASSWORD=your_password \
  opencode-railway
```

## 📚 Полезные ссылки

- [OpenCode Docs](https://opencode.ai/docs)
- [Oh-My-OpenAgent](https://github.com/code-yeongyu/oh-my-openagent)
- [Crush GitHub](https://github.com/charmbracelet/crush)
- [Railway Docs](https://docs.railway.com)

## 💡 Провайдеры

По умолчанию настроен **OpenCode Go** ($10/месяц):
- GLM-5
- Kimi K2.5
- MiniMax M2.5

Можно добавить другие провайдеры через переменные окружения или конфиг.

## 🔒 Безопасность

- Всегда устанавливай `OPENCODE_SERVER_PASSWORD` для публичных деплоев
- Railway предоставляет HTTPS по умолчанию
- API ключи хранятся в переменных окружения Railway (зашифрованы)

---

Made with ❤️ for AI-powered coding
