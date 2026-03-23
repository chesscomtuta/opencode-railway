#!/bin/bash
set -e

# OpenCode Railway Startup Script
# Configures and starts OpenCode Web Server with oh-my-opencode

echo "🚀 Starting OpenCode Server on Railway..."

# Railway provides PORT env var, default to 3000 if not set
PORT=${PORT:-3000}
echo "📡 Port: $PORT"

# Create config directory if not exists
mkdir -p /root/.config/opencode

# Generate opencode.json config
cat > /root/.config/opencode/opencode.json <<EOF
{
  "server": {
    "port": $PORT,
    "hostname": "0.0.0.0",
    "cors": []
  },
  "providers": {
    "opencode-go": {
      "id": "opencode-go",
      "name": "OpenCode Go",
      "type": "openai",
      "base_url": "https://api.opencode.ai/v1",
      "api_key": "${OPENCODE_GO_API_KEY:-}",
      "models": [
        {
          "id": "glm-5",
          "name": "GLM-5"
        },
        {
          "id": "kimi-k2.5",
          "name": "Kimi K2.5"
        },
        {
          "id": "minimax-m2.5",
          "name": "MiniMax M2.5"
        }
      ]
    }
  },
  "defaultProvider": "opencode-go",
  "defaultModel": "kimi-k2.5",
  "autoCompact": true,
  "options": {
    "context_paths": ["/app/projects"],
    "tui": {
      "compact_mode": false
    }
  }
}
EOF

echo "✅ Configuration created"

# Set authentication if password is provided
if [ -n "$OPENCODE_SERVER_PASSWORD" ]; then
    echo "🔒 Authentication enabled"
    export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
else
    echo "⚠️ No password set - server will be open"
fi

# Install/Update oh-my-opencode
if ! command -v oh-my-opencode &> /dev/null; then
    echo "📦 Installing oh-my-opencode..."
    npm install -g oh-my-opencode
fi

echo "🔧 Running oh-my-opencode installer..."

# Run oh-my-opencode installer with OpenCode Go settings
if [ -n "$OPENCODE_GO_API_KEY" ]; then
    bunx oh-my-opencode install --no-tui \
        --claude=no \
        --openai=no \
        --gemini=no \
        --copilot=no \
        --opencode-go=yes \
        --opencode-zen=no \
        --zai-coding-plan=no || true
else
    echo "⚠️ No OPENCODE_GO_API_KEY provided, skipping oh-my-opencode auto-config"
fi

echo "🌐 Starting OpenCode Web Server..."
echo "📍 Server will be available at: http://0.0.0.0:$PORT"

# Start OpenCode Web
exec opencode web --port "$PORT" --hostname 0.0.0.0
