# OpenCode Railway Deployment
# Includes: Crush (OpenCode) + oh-my-opencode + Web Interface

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
    && rm -rf /var/lib/apt/lists/*

# Install Bun (for oh-my-opencode)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Install Crush (OpenCode) from official source
# Crush is the successor to OpenCode
RUN curl -fsSL https://raw.githubusercontent.com/charmbracelet/crush/main/install.sh | bash

# Ensure crush is in PATH
ENV PATH="/usr/local/bin:${PATH}"

# Create workspace
WORKDIR /app

# Install oh-my-opencode
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
