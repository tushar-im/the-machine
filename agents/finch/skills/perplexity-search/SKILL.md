---
name: perplexity-search
description: Calls Perplexity Sonar API for citation-quality web research with source attribution.
trigger: When standard web search is insufficient, when citations are required, when academic/technical depth is needed
---

# Perplexity Search Skill

This skill calls the Perplexity Sonar API to get citation-quality search results with source attribution.

## Prerequisites

- `PERPLEXITY_API_KEY` environment variable must be set
- If not set, fall back to standard web search and note the limitation

## API Usage

### Basic Search Request

```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [{"role": "user", "content": "<research query>"}]
  }'
```

### Model Selection

| Model | Use When | Speed | Depth |
|---|---|---|---|
| `sonar-pro` | Deep research, comparisons, technical analysis | Slower | Very high |
| `sonar` | Quick factual lookups, simple questions | Fast | Moderate |

**Default to `sonar-pro`** for most research tasks. Use `sonar` only for simple yes/no or factual questions.

### Request Format

The API is OpenAI-compatible. Full request structure:

```json
{
  "model": "sonar-pro",
  "messages": [
    {
      "role": "system",
      "content": "You are a research assistant. Provide detailed, well-sourced answers. Always cite your sources with URLs."
    },
    {
      "role": "user",
      "content": "Your research query here"
    }
  ],
  "temperature": 0.2,
  "max_tokens": 4096
}
```

### Response Parsing

The response follows the OpenAI chat completion format. Extract:

1. **Answer**: `response.choices[0].message.content`
2. **Citations**: Look for URLs and source references in the response content

Parse with `jq`:

```bash
# Extract the answer
curl -s ... | jq -r '.choices[0].message.content'

# Full response with usage info
curl -s ... | jq '{answer: .choices[0].message.content, model: .model, usage: .usage}'
```

## Usage Patterns

### Quick Lookup

```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar",
    "messages": [{"role": "user", "content": "What is the latest stable version of Node.js as of March 2026?"}]
  }' | jq -r '.choices[0].message.content'
```

### Deep Research

```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [
      {"role": "system", "content": "Provide a comprehensive analysis with pros, cons, and source citations."},
      {"role": "user", "content": "Compare Bun vs Deno vs Node.js for production backend services in 2026. Include benchmarks, ecosystem maturity, and enterprise adoption."}
    ],
    "temperature": 0.1,
    "max_tokens": 8192
  }' | jq -r '.choices[0].message.content'
```

## Error Handling

### API Key Not Set

```bash
if [ -z "${PERPLEXITY_API_KEY:-}" ]; then
    echo "⚠️ PERPLEXITY_API_KEY not set. Falling back to standard web search."
    echo "Results may lack citation quality. Set the key for better research."
    # Fall back to Grok's native web search
    exit 0
fi
```

### API Error Responses

| HTTP Status | Meaning | Action |
|---|---|---|
| 200 | Success | Parse response normally |
| 401 | Invalid API key | Check PERPLEXITY_API_KEY value |
| 429 | Rate limited | Wait and retry after 60 seconds |
| 500+ | Server error | Retry once, then fall back to web search |

### Retry Logic

```bash
MAX_RETRIES=2
RETRY_DELAY=5

for i in $(seq 1 $MAX_RETRIES); do
    response=$(curl -s -w "\n%{http_code}" https://api.perplexity.ai/chat/completions \
      -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$request_body")

    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | head -n -1)

    if [ "$http_code" = "200" ]; then
        echo "$body" | jq -r '.choices[0].message.content'
        exit 0
    fi

    echo "⚠️ Attempt $i failed (HTTP $http_code). Retrying in ${RETRY_DELAY}s..."
    sleep $RETRY_DELAY
done

echo "❌ Perplexity API failed after $MAX_RETRIES attempts. Falling back to standard search."
```

## Integration with Intelligence Gatherer

When conducting research through the `intelligence-gatherer` skill:

1. Start with standard Grok web search for broad context
2. Use Perplexity (`sonar-pro`) for specific claims that need citations
3. Cross-reference Perplexity sources with information from Grok search
4. Flag any discrepancies between sources
5. Include Perplexity citations in your final report's Sources section
