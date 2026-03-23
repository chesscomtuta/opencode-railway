#!/bin/bash
set -e

echo "🚀 Starting OpenCode Web Server..."

PORT=${PORT:-3000}
echo "📡 Port: $PORT"

# Verify opencode
if ! command -v opencode &> /dev/null; then
    echo "❌ ERROR: opencode not found!"
    exit 1
fi

echo "✅ OpenCode: $(which opencode)"

# Config paths (using /data for persistence)
CONFIG_DIR="/data/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
mkdir -p "$CONFIG_DIR"

# Generate config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
{
  "server": {
    "port": $PORT,
    "hostname": "0.0.0.0"
  },
  "providers": {},
  "autoCompact": true,
  "options": {
    "context_paths": ["/data/projects"]
  }
}
EOF
    echo "✅ Config created at $CONFIG_FILE"
else
    echo "✅ Using existing config"
fi

# Set auth if provided
if [ -n "$OPENCODE_SERVER_PASSWORD" ]; then
    echo "🔒 Authentication enabled"
    export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
fi

echo "🌐 Starting on port $PORT..."
exec opencode web --port "$PORT" --hostname 0.0.0.0
