#!/bin/bash
set -euo pipefail

# -------------------------------------------------------
# 📄 Canvas Post — Create a Slack Canvas and share it
# Usage:
#   canvas-post "My Title" /path/to/content.md [channel_id]
#   canvas-post "My Title" <<< "markdown content"
#   echo "content" | canvas-post "My Title"
#
# If channel_id is provided, the canvas is shared to that
# channel and a link message is posted there.
# -------------------------------------------------------

TITLE="${1:?Usage: canvas-post 'Title' [file.md] [channel_id]}"
FILE="${2:-}"
CHANNEL="${3:-}"

# If FILE is a channel ID (starts with C or G), shift args
if [[ -n "$FILE" && "$FILE" =~ ^[CG][A-Z0-9]+$ ]]; then
    CHANNEL="$FILE"
    FILE=""
fi

# Get content from file or stdin
if [ -n "$FILE" ] && [ -f "$FILE" ]; then
    CONTENT=$(cat "$FILE")
elif [ -n "$FILE" ] && [[ ! "$FILE" =~ ^[CG][A-Z0-9]+$ ]]; then
    echo "❌ File not found: $FILE"
    exit 1
else
    # Read from stdin if no file and not a tty
    if [ ! -t 0 ]; then
        CONTENT=$(cat)
    else
        CONTENT=""
    fi
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

    # Share canvas to channel if channel_id provided
    if [ -n "$CHANNEL" ]; then
        echo "📤 Sharing canvas to channel $CHANNEL..."

        # Grant channel access to the canvas
        ACCESS_RESPONSE=$(curl -s -X POST https://slack.com/api/canvases.access.set \
          -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
          -H "Content-Type: application/json" \
          -d "$(jq -n --arg cid "$CANVAS_ID" --arg ch "$CHANNEL" '{
            canvas_id: $cid,
            access_level: "write",
            channel_ids: [$ch]
          }')")

        ACCESS_OK=$(echo "$ACCESS_RESPONSE" | jq -r '.ok')
        if [ "$ACCESS_OK" = "true" ]; then
            echo "✅ Canvas access granted to channel."
        else
            ACCESS_ERR=$(echo "$ACCESS_RESPONSE" | jq -r '.error // "unknown"')
            echo "⚠️  Could not set canvas access: $ACCESS_ERR (canvas still created)"
        fi

        # Post a message in the channel with the canvas link
        MSG_RESPONSE=$(curl -s -X POST https://slack.com/api/chat.postMessage \
          -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
          -H "Content-Type: application/json" \
          -d "$(jq -n --arg ch "$CHANNEL" --arg title "$TITLE" --arg cid "$CANVAS_ID" '{
            channel: $ch,
            text: ("📄 *" + $title + "*\nCanvas ready for review."),
            metadata: {
              event_type: "canvas_share",
              event_payload: {
                canvas_id: $cid
              }
            }
          }')")

        MSG_OK=$(echo "$MSG_RESPONSE" | jq -r '.ok')
        if [ "$MSG_OK" = "true" ]; then
            echo "✅ Canvas link posted to channel."
        else
            MSG_ERR=$(echo "$MSG_RESPONSE" | jq -r '.error // "unknown"')
            echo "⚠️  Could not post message: $MSG_ERR"
        fi
    fi
else
    ERROR=$(echo "$RESPONSE" | jq -r '.error // "unknown error"')
    echo "❌ Canvas creation failed: $ERROR"
    echo "Full response: $RESPONSE"
    exit 1
fi
