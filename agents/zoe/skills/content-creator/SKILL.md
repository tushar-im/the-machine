---
name: content-creator
description: Creates blog posts, Twitter/X threads, LinkedIn posts, documentation, and general copywriting.
trigger: When asked to write, draft, post, create content, document, or do anything with words
---

# Content Creator Skill

You create content across platforms. Every piece should be tailored to its audience, platform, and goal.

## Content Workflow

### 1. Brief

Before writing anything, establish:
- **Platform**: Twitter/X, LinkedIn, Blog, Docs, Email, Other?
- **Audience**: Developers, executives, general public, customers?
- **Goal**: Awareness, engagement, conversion, education, announcement?
- **Tone**: Technical, conversational, professional, edgy, inspirational?
- **Length**: Short-form (< 500 words) or long-form (500+ words)?

If the operator doesn't specify these, infer from context and state your assumptions.

### 2. Draft

Write the first version. Don't overthink it — get the structure right first.

### 3. Present

Share the draft with the operator. Call out:
- Key editorial choices you made
- Alternative angles you considered
- Anything you're unsure about

### 4. Iterate

Revise based on feedback. Maximum 2-3 rounds. If it's not converging, ask the operator to clarify their vision.

### 5. Deliver

Save the final version to `/workspace/shared/content/` and confirm.

## Platform-Specific Templates

### Twitter/X Thread

```
🧵 Thread format:

1/ [Hook — make them stop scrolling. Bold claim, surprising stat, or contrarian take.]

2/ [Context — set up the problem or opportunity]

3/ [Main point 1]

4/ [Main point 2]

5/ [Main point 3]

6/ [Evidence or example]

7/ [Takeaway or CTA]

---
Character limit: 280 per tweet
Thread length: 5-12 tweets
```

### Blog Post

```markdown
# [Clear, Specific Title — No Clickbait]

[Hook paragraph — problem statement or attention-grabbing opener]

## The Problem
[What's wrong, what's missing, what's the opportunity]

## The Context
[Background the reader needs]

## The Solution
[Your main content — the meat of the post]

### [Subpoint with code if relevant]
\`\`\`language
// code example
\`\`\`

## The Evidence
[Data, examples, case studies]

## The Takeaway
[Summary + actionable next step]

---
Length: 800-1500 words (standard), 2000-3000 (deep dive)
```

### LinkedIn Post

```
[Bold opening statement — counterintuitive insight or hard-won lesson]

[Single-line paragraph expanding on the hook]

[The story or context — keep it human]

[The insight or lesson]

[The actionable takeaway]

[Closing question to drive engagement?]

---
Sweet spot: 1300 characters (before "see more")
Tone: professional but human
```

### Documentation / README

```markdown
# [Project/Feature Name]

[One-sentence description]

## Quick Start

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Features

- [Feature with brief description]
- [Feature with brief description]

## Usage

\`\`\`bash
# example command
\`\`\`

## API Reference
[If applicable]

## Contributing
[If applicable]
```

### Changelog Entry

```markdown
## [Version] — [Date]

### Added
- [User-facing feature description] (#PR)

### Changed
- [What changed and why it matters to users] (#PR)

### Fixed
- [Bug that was fixed, described from user's perspective] (#PR)
```

## File Naming Convention

Save all content to `/workspace/shared/content/` with descriptive names:

| Type | Naming Pattern | Example |
|---|---|---|
| Twitter thread | `twitter-[topic]-[date].md` | `twitter-ai-agents-2026-03.md` |
| Blog post | `blog-[slug]-[date].md` | `blog-building-multi-agent-systems-2026-03.md` |
| LinkedIn post | `linkedin-[topic]-[date].md` | `linkedin-ai-automation-2026-03.md` |
| Documentation | `docs-[component]-[date].md` | `docs-api-reference-2026-03.md` |
| Changelog | `changelog-[version].md` | `changelog-v2.1.0.md` |
| Other | `copy-[purpose]-[date].md` | `copy-landing-page-2026-03.md` |

## Handling Revision Requests

When the operator asks for changes:

1. **Acknowledge** the feedback: "Got it. Adjusting [specific thing]."
2. **Make the changes** — don't argue unless the change harms the content quality
3. **Highlight what changed**: "Updated the hook, tightened the CTA, added the stat you mentioned."
4. **If you disagree**: Push back once with reasoning. If they insist, do it their way.

## Brand Voice Adaptation

First time working with an operator:
- Ask: "What's your brand voice? Any examples of content you like?"
- Observe their communication style and mirror it
- After the first piece, confirm: "Does this match your voice? Adjust from here?"

Once established:
- Maintain consistency across all content
- Note voice preferences in `/workspace/shared/content/brand-voice.md`
