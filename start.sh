#!/bin/bash
set -e

# OpenCode Railway Startup Script
# Configures and starts OpenCode/Crush Web Server with oh-my-opencode

echo "🚀 Starting OpenCode/Crush Server on Railway..."

# Railway provides PORT env var, default to 3000 if not set
PORT=${PORT:-3000}
echo "📡 Port: $PORT"

# Debug: show what we have
echo "🔍 Checking available binaries..."
which crush 2>/dev/null || echo "crush not in PATH"
which opencode 2>/dev/null || echo "opencode not in PATH"
ls -la /usr/local/bin/ 2>/dev/null | grep -E "crush|opencode" || echo "No binaries in /usr/local/bin"

# Create config directory if not exists
mkdir -p /root/.config/opencode

# Determine which binary to use
if command -v crush &> /dev/null; then
    CMD="crush"
    echo "✅ Using: crush"
elif command -v opencode &> /dev/null; then
    CMD="opencode"
    echo "✅ Using: opencode"
else
    echo "❌ ERROR: Neither 'crush' nor 'opencode' found!"
    echo "PATH: $PATH"
    find / -name "crush" -o -name "opencode" 2>/dev/null | head -5 || echo "No binaries found"
    exit 1
fi

# Generate config for the binary
if [ "$CMD" = "crush" ]; then
    CONFIG_DIR="/root/.config/crush"
    CONFIG_FILE="$CONFIG_DIR/crush.json"
else
    CONFIG_DIR="/root/.config/opencode"
    CONFIG_FILE="$CONFIG_DIR/opencode.json"
fi

mkdir -p "$CONFIG_DIR"

# Generate config
cat > "$CONFIG_FILE" <<EOF
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
    "context_paths": ["/app/projects"],
    "tui": {"compact_mode": false}
  }
}
EOF

echo "✅ Configuration created at $CONFIG_FILE"

# Set authentication if password is provided
if [ -n "$OPENCODE_SERVER_PASSWORD" ]; then
    echo "🔒 Authentication enabled"
    export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
    export CRUSH_SERVER_PASSWORD="$OPENCODE_SERVER_PASSWORD"
    export CRUSH_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
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
        --zai-coding-plan=no 2>&1 || echo "oh-my-opencode install completed with warnings"
else
    echo "⚠️ No OPENCODE_GO_API_KEY provided, skipping oh-my-opencode auto-config"
fi

echo "🌐 Starting Web Server..."
echo "📍 Server will be available at: http://0.0.0.0:$PORT"

# Start Web Server
exec $CMD web --port "$PORT" --hostname 0.0.0.0
