# OpenCode Railway with Volume
# OpenCode Web UI + /data volume для persistence

FROM node:20-bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Install OpenCode CLI
RUN npm install -g @opencode-ai/cli

# Create /data directory for volume
RUN mkdir -p /data/projects /data/.config/opencode

# Set proper permissions
ENV HOME=/data
ENV XDG_CONFIG_HOME=/data/.config

# Create workspace
WORKDIR /data/projects

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose port
EXPOSE 3000

# Start
CMD ["/app/start.sh"]
