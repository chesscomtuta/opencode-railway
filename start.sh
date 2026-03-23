#!/bin/bash
set -e

echo "🚀 Starting OpenCode Server on Railway..."

PORT=${PORT:-3000}
echo "📡 Port: $PORT"

# Verify opencode is available
if ! command -v opencode &> /dev/null; then
    echo "❌ ERROR: opencode not found in PATH!"
    echo "PATH: $PATH"
    ls -la /usr/local/bin/ /root/.local/bin/ 2>/dev/null || true
    exit 1
fi

echo "✅ OpenCode found: $(which opencode)"
opencode --version || echo "Version check skipped"

# Create config directory
mkdir -p /root/.config/opencode

# Generate config
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
        {"id": "glm-5", "name": "GLM-5"},
        {"id": "kimi-k2.5", "name": "Kimi K2.5"},
        {"id": "minimax-m2.5", "name": "MiniMax M2.5"}
      ]
    }
  },
  "defaultProvider": "opencode-go",
  "defaultModel": "kimi-k2.5",
  "autoCompact": true,
  "options": {
    "context_paths": ["/app/projects"]
  }
}
EOF

echo "✅ Configuration created"

# Set auth if provided
if [ -n "$OPENCODE_SERVER_PASSWORD" ]; then
    echo "🔒 Authentication enabled"
    export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
else
    echo "⚠️ No password set - server will be open"
fi

# Run oh-my-opencode installer
if [ -n "$OPENCODE_GO_API_KEY" ]; then
    echo "🔧 Configuring oh-my-opencode..."
    bunx oh-my-opencode install --no-tui \
        --claude=no --openai=no --gemini=no --copilot=no \
        --opencode-go=yes --opencode-zen=no --zai-coding-plan=no 2>&1 || \
        echo "oh-my-opencode completed with warnings"
fi

echo "🌐 Starting OpenCode Web Server on port $PORT..."
exec opencode web --port "$PORT" --hostname 0.0.0.0
