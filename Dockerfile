# OpenCode Railway Deployment
# Includes: OpenCode + Oh-My-OpenAgent + Web Interface

FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    unzip \
    nodejs \
    npm \
    golang-go \
    build-essential \
    libc6 \
    && rm -rf /var/lib/apt/lists/*

# Install Bun (for oh-my-opencode)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Install OpenCode (Crush) - download pre-built binary
# Crush is the successor to OpenCode from Charm Bracelet
RUN set -e && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) ARCH="x86_64" ;; \
        aarch64) ARCH="arm64" ;; \
        *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
    esac && \
    echo "Downloading Crush for ${ARCH}..." && \
    curl -fsSL "https://github.com/charmbracelet/crush/releases/latest/download/crush_Linux_${ARCH}.tar.gz" -o /tmp/crush.tar.gz || \
    (echo "Trying zip..." && curl -fsSL "https://github.com/charmbracelet/crush/releases/latest/download/crush_Linux_${ARCH}.zip" -o /tmp/crush.zip) && \
    if [ -f /tmp/crush.tar.gz ]; then \
        tar -xzf /tmp/crush.tar.gz -C /usr/local/bin crush || tar -xzf /tmp/crush.tar.gz -C /usr/local/bin; \
    else \
        unzip -o /tmp/crush.zip -d /usr/local/bin; \
    fi && \
    chmod +x /usr/local/bin/crush 2>/dev/null || true && \
    ls -la /usr/local/bin/ | grep -i crush || echo "Crush not found in /usr/local/bin" && \
    rm -f /tmp/crush.tar.gz /tmp/crush.zip

# Try alternative: install opencode via their install script
RUN set -e && \
    if ! command -v crush &> /dev/null; then \
        echo "Trying OpenCode install script..." && \
        curl -fsSL https://opencode.ai/install.sh | sh || true; \
    fi

# Add to PATH
ENV PATH="/usr/local/bin:/root/.local/bin:${PATH}"

# Verify installation
RUN which crush || which opencode || echo "WARNING: Neither crush nor opencode found"

# Create workspace
WORKDIR /app

# Install oh-my-opencode globally
RUN npm install -g oh-my-opencode

# Copy configuration files
COPY config/opencode.json /root/.config/opencode/opencode.json
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create projects directory
RUN mkdir -p /app/projects

# Expose port (Railway will set PORT env var)
EXPOSE 3000

# Start the server
CMD ["/app/start.sh"]
