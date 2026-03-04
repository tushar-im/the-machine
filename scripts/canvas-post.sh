#!/bin/bash
set -euo pipefail

# -------------------------------------------------------
# 📄 Canvas Post — Create a Slack Canvas from a file or stdin
# Usage:
#   canvas-post "My Title" /path/to/content.md
#   canvas-post "My Title" <<< "markdown content"
#   echo "content" | canvas-post "My Title"
# -------------------------------------------------------

TITLE="${1:?Usage: canvas-post 'Title' [file.md]}"
FILE="${2:-}"

# Get content from file or stdin
if [ -n "$FILE" ] && [ -f "$FILE" ]; then
    CONTENT=$(cat "$FILE")
elif [ -n "$FILE" ]; then
    echo "❌ File not found: $FILE"
    exit 1
else
    # Read from stdin
    CONTENT=$(cat)
fi

if [ -z "$CONTENT" ]; then
    echo "❌ No content provided."
    exit 1
fi

if [ -z "${SLACK_BOT_TOKEN:-}" ]; then
    echo "❌ SLACK_BOT_TOKEN not set."
    exit 1
fi

echo "📄 Creating Slack Canvas: \"$TITLE\"..."

# Create canvas via Slack API using jq for proper JSON escaping
RESPONSE=$(curl -s -X POST https://slack.com/api/canvases.create \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg title "$TITLE" --arg md "$CONTENT" '{
    title: $title,
    document_content: {
      type: "markdown",
      markdown: $md
    }
  }')")

# Check response
OK=$(echo "$RESPONSE" | jq -r '.ok')
if [ "$OK" = "true" ]; then
    CANVAS_ID=$(echo "$RESPONSE" | jq -r '.canvas_id')
    echo "✅ Canvas created successfully!"
    echo "   Canvas ID: $CANVAS_ID"
    echo "   Title: $TITLE"
    echo "   Content length: $(echo "$CONTENT" | wc -c | tr -d ' ') bytes"
else
    ERROR=$(echo "$RESPONSE" | jq -r '.error // "unknown error"')
    echo "❌ Canvas creation failed: $ERROR"
    echo "Full response: $RESPONSE"
    exit 1
fi
