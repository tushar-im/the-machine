#!/bin/bash
set -euo pipefail

# -------------------------------------------------------
# 📡 The Machine Squad — Lean Agent Entrypoint
# For: The Machine, Finch, Zoe (Grok 4.1 Fast via xAI)
# -------------------------------------------------------

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         📡 THE MACHINE SQUAD — LEAN AGENT           ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Agent:  ${AGENT_DISPLAY_NAME:-Unknown}              "
echo "║  Role:   ${AGENT_ROLE:-Unknown}                      "
echo "║  Model:  ${MODEL:-Unknown}                           "
echo "║  Port:   ${GATEWAY_PORT:-Unknown}                    "
echo "╠══════════════════════════════════════════════════════╣"
echo "║           \"You are being watched.\"                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# -------------------------------------------------------
# 1. Validate required environment variables
# -------------------------------------------------------
REQUIRED_VARS=("API_KEY" "SLACK_BOT_TOKEN" "SLACK_APP_TOKEN" "SLACK_USER_ID" "MODEL" "GATEWAY_PORT")

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "❌ FATAL: Required environment variable $var is not set."
        exit 1
    fi
done

echo "✅ All required environment variables validated."

# -------------------------------------------------------
# 2. Copy config template and replace placeholders
# -------------------------------------------------------
CONFIG_TEMPLATE="/root/.zeroclaw/config.toml.template"
CONFIG_FILE="/root/.zeroclaw/config.toml"

if [ ! -f "$CONFIG_TEMPLATE" ]; then
    echo "❌ FATAL: Config template not found at $CONFIG_TEMPLATE"
    exit 1
fi

cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

# Replace all PLACEHOLDER_* tokens with env var values
sed -i "s|PLACEHOLDER_API_KEY|${API_KEY}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_API_BASE_URL|${API_BASE_URL:-https://api.x.ai/v1}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_MODEL|${MODEL}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_TEMPERATURE|${TEMPERATURE:-0.7}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_SLACK_BOT_TOKEN|${SLACK_BOT_TOKEN}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_SLACK_APP_TOKEN|${SLACK_APP_TOKEN}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_SLACK_USER_ID|${SLACK_USER_ID}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_GATEWAY_PORT|${GATEWAY_PORT}|g" "$CONFIG_FILE"

# Optional: Perplexity API key (Finch only)
if [ -n "${PERPLEXITY_API_KEY:-}" ]; then
    sed -i "s|PLACEHOLDER_PERPLEXITY_API_KEY|${PERPLEXITY_API_KEY}|g" "$CONFIG_FILE"
    echo "✅ Perplexity API key configured."
else
    # Remove or leave placeholder if not set
    sed -i "s|PLACEHOLDER_PERPLEXITY_API_KEY||g" "$CONFIG_FILE"
    echo "ℹ️  Perplexity API key not set (optional)."
fi

echo "✅ ZeroClaw config generated at $CONFIG_FILE"

# -------------------------------------------------------
# 3. Set up shared workspace directories
# -------------------------------------------------------
mkdir -p /workspace/projects
mkdir -p /workspace/shared/intel
mkdir -p /workspace/shared/content
mkdir -p /workspace/shared/status

echo "✅ Workspace directories ready."

# -------------------------------------------------------
# 4. Run diagnostics
# -------------------------------------------------------
echo ""
echo "--- Diagnostics ---"
echo "Node.js: $(node --version 2>/dev/null || echo 'not found')"
echo "npm:     $(npm --version 2>/dev/null || echo 'not found')"
echo "Python:  $(python3 --version 2>/dev/null || echo 'not found')"
echo "Git:     $(git --version 2>/dev/null || echo 'not found')"
echo "ZeroClaw: $(zeroclaw --version 2>/dev/null || echo 'not found')"
echo "-------------------"
echo ""

# -------------------------------------------------------
# 5. Launch ZeroClaw daemon
# -------------------------------------------------------
echo "🚀 Starting ZeroClaw daemon for ${AGENT_DISPLAY_NAME:-agent}..."
exec zeroclaw daemon
