# OpenCode Railway Deployment
# OpenCode + Oh-My-OpenAgent + Web UI

FROM node:20-bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Bun (required for oh-my-opencode)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Install OpenCode CLI via npm (most reliable)
RUN npm install -g @opencode-ai/cli || \
    (echo "npm install failed, trying alternative..." && \
     curl -fsSL https://opencode.ai/install.sh | bash)

# Ensure opencode is available
ENV PATH="/usr/local/bin:/root/.local/bin:${PATH}"

# Verify installation
RUN which opencode || (echo "ERROR: opencode not found!" && exit 1)
RUN opencode --version || echo "Version check failed"

# Create workspace
WORKDIR /app

# Install oh-my-opencode
RUN npm install -g oh-my-opencode

# Copy configuration
RUN mkdir -p /root/.config/opencode
COPY config/opencode.json /root/.config/opencode/opencode.json
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create projects directory
RUN mkdir -p /app/projects

# Expose port
EXPOSE 3000

# Start
CMD ["/app/start.sh"]
