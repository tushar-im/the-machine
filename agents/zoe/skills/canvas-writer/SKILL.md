---
name: canvas-writer
description: Creates Slack Canvases for long-form content using the canvas-post command.
trigger: When content exceeds 500 words, when writing blog posts, research reports, architecture docs, or any structured long-form deliverable
---

# Canvas Writer Skill

Create Slack Canvases for long-form content using the `canvas-post` command.

## When to Use

**Use Canvas for:**
- Blog posts, articles, deep dives
- Research reports, comparison tables, intel briefs
- Architecture docs, build plans
- Any content >500 words or with rich structure

**Use regular message for:**
- Short replies, status updates, quick answers
- Twitter threads (post as numbered list)
- Content <300 words

## How to Create a Canvas

### From a file:

```bash
canvas-post "Your Canvas Title" /path/to/content.md
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
4. The script will create the Canvas and return the Canvas ID
5. Reply to the operator: "📄 Posted to Canvas: [Title]. Ready for review."

## Example

```bash
# Write the blog post
cat > /workspace/shared/content/blog-multi-agent-ai.md << 'EOF'
# Building The Machine: A Multi-Agent AI Squad

In the world of AI development...
(full content here)
EOF

# Post it to Canvas
canvas-post "Building The Machine: A Multi-Agent AI Squad" /workspace/shared/content/blog-multi-agent-ai.md
```

## After Creating a Canvas

Always reply to the operator with a brief summary:

```
📄 Posted to Canvas: "[Title]"
Key angle: [one-sentence summary]
Ready for review.
```
