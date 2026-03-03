#!/bin/bash
set -euo pipefail

# -------------------------------------------------------
# 🔫 Reese — Full Build Agent Entrypoint
# GLM-5 via Z.AI + Claude Code + create-01x-project
# -------------------------------------------------------

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         🔫 REESE — FULL BUILD AGENT                 ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Agent:  ${AGENT_DISPLAY_NAME:-Reese}                "
echo "║  Role:   ${AGENT_ROLE:-Software Engineer}            "
echo "║  Model:  ${MODEL:-glm-5}                             "
echo "║  Port:   ${GATEWAY_PORT:-42618}                      "
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
# 2. Configure Claude Code CLI to use Z.AI backend
# -------------------------------------------------------
mkdir -p /root/.claude

cat > /root/.claude/settings.json << EOF
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "${API_KEY}",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air"
  },
  "model": "glm-5"
}
EOF

echo "✅ Claude Code configured for Z.AI backend."

# -------------------------------------------------------
# 3. Configure git credentials (if GITHUB_TOKEN set)
# -------------------------------------------------------
if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "https://${GITHUB_TOKEN}@github.com" > /root/.git-credentials
    git config --global credential.helper store
    echo "✅ GitHub credentials configured."
else
    echo "ℹ️  No GITHUB_TOKEN set — git auth not configured."
fi

if [ -n "${GIT_USER_NAME:-}" ]; then
    git config --global user.name "${GIT_USER_NAME}"
fi

if [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "${GIT_USER_EMAIL}"
fi

# -------------------------------------------------------
# 4. Copy config template and replace placeholders
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
sed -i "s|PLACEHOLDER_API_BASE_URL|${API_BASE_URL:-https://api.z.ai/api/coding/paas/v4}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_MODEL|${MODEL}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_TEMPERATURE|${TEMPERATURE:-0.4}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_SLACK_BOT_TOKEN|${SLACK_BOT_TOKEN}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_SLACK_APP_TOKEN|${SLACK_APP_TOKEN}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_SLACK_USER_ID|${SLACK_USER_ID}|g" "$CONFIG_FILE"
sed -i "s|PLACEHOLDER_GATEWAY_PORT|${GATEWAY_PORT}|g" "$CONFIG_FILE"

echo "✅ ZeroClaw config generated at $CONFIG_FILE"

# -------------------------------------------------------
# 5. Set up workspace directories
# -------------------------------------------------------
mkdir -p /workspace/projects
mkdir -p /workspace/shared/intel
mkdir -p /workspace/shared/content
mkdir -p /workspace/shared/status

echo "✅ Workspace directories ready."

# -------------------------------------------------------
# 6. Run diagnostics
# -------------------------------------------------------
echo ""
echo "--- Diagnostics ---"
echo "Node.js:           $(node --version 2>/dev/null || echo 'not found')"
echo "npm:               $(npm --version 2>/dev/null || echo 'not found')"
echo "Python:            $(python3 --version 2>/dev/null || echo 'not found')"
echo "Git:               $(git --version 2>/dev/null || echo 'not found')"
echo "Rust:              $(rustc --version 2>/dev/null || echo 'not found')"
echo "Cargo:             $(cargo --version 2>/dev/null || echo 'not found')"
echo "Claude Code:       $(claude --version 2>/dev/null || echo 'not found')"
echo "create-01x-project: $(npx create-01x-project --version 2>/dev/null || echo 'not found')"
echo "ZeroClaw:          $(zeroclaw --version 2>/dev/null || echo 'not found')"
echo "build-handler:     $(which build-handler 2>/dev/null || echo 'not found')"
echo "-------------------"
echo ""

# -------------------------------------------------------
# 7. Launch ZeroClaw daemon
# -------------------------------------------------------
echo "🚀 Starting ZeroClaw daemon for ${AGENT_DISPLAY_NAME:-Reese}..."
exec zeroclaw daemon
