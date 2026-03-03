FROM ubuntu:24.04

# -------------------------------------------------------
# 📡 The Machine Squad — Lean Agent Image
# For: The Machine, Finch, Zoe (Grok 4.1 Fast via xAI)
# -------------------------------------------------------

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies (minimal)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    python3-venv \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 (required for ZeroClaw)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Rust + ZeroClaw
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install zeroclaw --locked || \
    (git clone https://github.com/zeroclaw-labs/zeroclaw.git /tmp/zeroclaw && \
     cd /tmp/zeroclaw && \
     cargo build --release && \
     cp target/release/zeroclaw /usr/local/bin/ && \
     rm -rf /tmp/zeroclaw)

# Create directories
RUN mkdir -p /workspace/projects \
    /workspace/shared \
    /root/.zeroclaw/workspace/skills

# Git defaults
RUN git config --global credential.helper store \
    && git config --global init.defaultBranch main

# Copy entrypoint
COPY scripts/entrypoint-lean.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
