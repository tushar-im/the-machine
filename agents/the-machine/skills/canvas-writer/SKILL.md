---
name: canvas-writer
description: Creates Slack Canvases for long-form content using the canvas-post command.
trigger: When content exceeds 500 words, when writing blog posts, research reports, architecture docs, or any structured long-form deliverable
---

# Canvas Writer Skill

Create Slack Canvases for long-form content using the `canvas-post` command.

## When to Use

**ALWAYS use Canvas for:**
- Blog posts, articles, deep dives
- Research reports, comparison tables, intel briefs
- Architecture docs, build plans
- Any content >500 words or with rich structure
- Any task where the operator asks for a "write-up", "report", "draft", or "document"

**Use regular message for:**
- Short replies, status updates, quick answers
- Twitter threads (post as numbered list)
- Content <300 words

**IMPORTANT**: If your response is going to be long (>500 words), you MUST use Canvas. Do not dump walls of text into Slack messages. Write it as a Canvas instead.

## How to Create a Canvas

### From a file (recommended):

```bash
canvas-post "Your Canvas Title" /path/to/content.md
```

### From a file, shared to a channel:

```bash
canvas-post "Your Canvas Title" /path/to/content.md C0123CHANNEL
```

### From inline content:

```bash
cat << 'EOF' | canvas-post "Your Canvas Title"
# Your Markdown Content

Write your full blog post, report, or document here.

## Section 1
Content...

## Section 2
More content...
EOF
```

### Workflow

1. Write your content in markdown
2. Save it to a file (e.g., `/workspace/shared/content/my-post.md`)
3. Run: `canvas-post "Title" /workspace/shared/content/my-post.md`
4. The script will create the Canvas, set channel access, and post a link
5. Reply to the operator: "📄 Posted to Canvas: [Title]. Ready for review."

## Getting the Channel ID

When you receive a message from Slack, the channel ID is in the message metadata. Use the channel ID from the current conversation to share the canvas there:

```bash
# If you know the channel ID from the conversation context:
canvas-post "Title" /workspace/shared/content/file.md C0123CHANNEL
```

If you don't have the channel ID, just create the canvas without it — the operator can still find it in the workspace canvas list.

## Example

```bash
# Write the blog post
cat > /workspace/shared/content/blog-multi-agent-ai.md << 'EOF'
# Building The Machine: A Multi-Agent AI Squad

In the world of AI development...
(full content here)
EOF

# Post it to Canvas (with optional channel sharing)
canvas-post "Building The Machine: A Multi-Agent AI Squad" /workspace/shared/content/blog-multi-agent-ai.md
```

## After Creating a Canvas

Always reply to the operator with a brief summary:

```
📄 Posted to Canvas: "[Title]"
Key angle: [one-sentence summary]
Ready for review.
```
