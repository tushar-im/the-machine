# Setup Guide — The Machine

Step-by-step deployment guide for the multi-agent squad system.

## Prerequisites

- **Docker** (v24+) and **Docker Compose** (v2+)
- A Linux host (Oracle Cloud free tier recommended, or any VPS with 2+ GB RAM)
- A **Slack workspace** you administer
- API keys:
  - [xAI API Key](https://console.x.ai/) — for Machine, Finch, Zoe
  - [Z.AI API Key](https://z.ai/) — for Reese
  - [Perplexity API Key](https://docs.perplexity.ai/) — for Finch (optional)

## Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/the-machine.git
cd the-machine
```

## Step 2: Create 4 Slack Apps

Follow the [Slack Setup Guide](SLACK_SETUP.md) to create 4 Slack apps (The Machine, Reese, Finch, Zoe) and collect their tokens.

You'll need:
- 4 Bot Tokens (xoxb-...)
- 4 App-Level Tokens (xapp-...)
- Your Slack Member ID (U...)

## Step 3: Get API Keys

| Provider | URL | Used By |
|---|---|---|
| xAI | https://console.x.ai/ | Machine, Finch, Zoe |
| Z.AI | https://z.ai/ | Reese |
| Perplexity | https://docs.perplexity.ai/ | Finch (optional) |

## Step 4: Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and fill in all values:

```bash
# Required
XAI_API_KEY=xai-your-key-here
ZAI_API_KEY=your-zai-key-here
SLACK_USER_ID=U0123456789

MACHINE_SLACK_BOT_TOKEN=xoxb-...
MACHINE_SLACK_APP_TOKEN=xapp-...
REESE_SLACK_BOT_TOKEN=xoxb-...
REESE_SLACK_APP_TOKEN=xapp-...
FINCH_SLACK_BOT_TOKEN=xoxb-...
FINCH_SLACK_APP_TOKEN=xapp-...
ZOE_SLACK_BOT_TOKEN=xoxb-...
ZOE_SLACK_APP_TOKEN=xapp-...

# Optional
PERPLEXITY_API_KEY=pplx-...
GITHUB_TOKEN=ghp_...
```

## Step 5: Build Docker Images

```bash
docker compose build
```

This builds two images:
- **Lean image** (Dockerfile.lean) — for Machine, Finch, Zoe (~2 GB)
- **Full image** (Dockerfile.full) — for Reese (~4 GB, includes Claude Code)

First build takes 10-15 minutes.

## Step 6: Start All Agents

```bash
docker compose up -d
```

This starts all 4 agent containers in the background.

## Step 7: Verify

Check that all containers are running:

```bash
docker compose ps
```

Check individual agent logs:

```bash
docker compose logs the-machine
docker compose logs reese
docker compose logs finch
docker compose logs zoe
```

Look for:
- ✅ "All required environment variables validated"
- ✅ "ZeroClaw config generated"
- 🚀 "Starting ZeroClaw daemon"

## Step 8: Set Up Slack

1. Create `#machine-room` channel in your Slack workspace
2. Invite all 4 bots to `#machine-room`
3. Optionally add individual agents to relevant channels:
   - Reese → `#engineering`
   - Finch → `#research`
   - Zoe → `#content`

## Step 9: Test

DM **The Machine** in Slack:

```
status
```

It should respond with a squad status report showing all agent states.

## Troubleshooting

### Container won't start
```bash
docker compose logs <agent-name>
```
Check for missing env vars (❌ FATAL messages).

### Agent not responding in Slack
- Verify the bot is invited to the channel
- Check that `SLACK_USER_ID` matches your actual Slack member ID
- Ensure Socket Mode is enabled for the Slack app

### Build failures
```bash
# Rebuild a single agent
docker compose build <service-name>

# Rebuild everything from scratch
docker compose build --no-cache
```

### Viewing agent memory
```bash
docker compose exec the-machine ls -la /root/.zeroclaw/memory/
```

## Updating

```bash
git pull
docker compose build
docker compose up -d
```
