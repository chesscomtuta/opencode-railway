# OpenCode Railway Deployment
# Includes: OpenCode (Crush) + Oh-My-OpenAgent + Web Interface

FROM golang:1.23-bookworm AS builder

# Build crush from source (most reliable method)
RUN set -e && \
    echo "Building Crush from source..." && \
    go install github.com/charmbracelet/crush@latest || \
    (echo "Failed to install crush, will try alternative" && exit 0)

# Final stage
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    unzip \
    nodejs \
    npm \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Bun (for oh-my-opencode)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Copy crush binary from builder
COPY --from=builder /go/bin/crush /usr/local/bin/crush || true

# If crush not found, try alternative installation methods
RUN set -e && \
    if ! command -v crush &> /dev/null; then \
        echo "Trying to download Crush binary..." && \
        CRUSH_VERSION="v0.1.0" && \
        ARCH=$(dpkg --print-architecture) && \
        case "$ARCH" in \
            amd64) ARCH="x86_64" ;; \
            arm64) ARCH="arm64" ;; \
        esac && \
        curl -fsSL "https://github.com/charmbracelet/crush/releases/download/${CRUSH_VERSION}/crush_${CRUSH_VERSION#v}_Linux_${ARCH}.tar.gz" -o /tmp/crush.tar.gz 2>/dev/null && \
        tar -xzf /tmp/crush.tar.gz -C /usr/local/bin 2>/dev/null || \
        (echo "Trying .zip..." && \
         curl -fsSL "https://github.com/charmbracelet/crush/releases/download/${CRUSH_VERSION}/crush_${CRUSH_VERSION#v}_Linux_${ARCH}.zip" -o /tmp/crush.zip 2>/dev/null && \
         unzip -o /tmp/crush.zip -d /usr/local/bin 2>/dev/null) || \
        echo "WARNING: Could not install crush"; \
        rm -f /tmp/crush.tar.gz /tmp/crush.zip 2>/dev/null || true; \
    fi && \
    chmod +x /usr/local/bin/crush 2>/dev/null || true && \
    ls -la /usr/local/bin/ 2>/dev/null | head -20

# Alternative: Install original OpenCode if crush not available
RUN set -e && \
    if ! command -v crush &> /dev/null; then \
        echo "Installing original OpenCode..." && \
        curl -fsSL https://raw.githubusercontent.com/opencode-ai/opencode/main/install.sh | bash || \
        (echo "OpenCode install script failed" && exit 0); \
    fi

# Add to PATH
ENV PATH="/usr/local/bin:/root/.local/bin:${PATH}"

# Verify and create symlinks
RUN set -e && \
    if command -v crush &> /dev/null; then \
        echo "✅ Crush installed at: $(which crush)" && \
        ln -sf $(which crush) /usr/local/bin/opencode 2>/dev/null || true; \
    elif command -v opencode &> /dev/null; then \
        echo "✅ OpenCode installed at: $(which opencode)" && \
        ln -sf $(which opencode) /usr/local/bin/crush 2>/dev/null || true; \
    else \
        echo "❌ WARNING: Neither crush nor opencode found!"; \
    fi && \
    which crush || which opencode || echo "Binary not in PATH"

# Create workspace
WORKDIR /app

# Install oh-my-opencode globally
RUN npm install -g oh-my-opencode

# Copy configuration files
RUN mkdir -p /root/.config/opencode
COPY config/opencode.json /root/.config/opencode/opencode.json
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create projects directory
RUN mkdir -p /app/projects

# Expose port (Railway will set PORT env var)
EXPOSE 3000

# Start the server
CMD ["/app/start.sh"]
