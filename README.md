# The Machine

> "You are being watched."

A 4-agent AI squad running on [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw) + Docker Compose. Inspired by Person of Interest.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        SLACK WORKSPACE                       │
│                                                              │
│  ┌─────────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
│  │ #machine-   │  │  DMs    │  │  #eng   │  │#content │   │
│  │   room      │  │         │  │         │  │         │   │
│  └──────┬──────┘  └────┬────┘  └────┬────┘  └────┬────┘   │
│         │              │            │             │          │
└─────────┼──────────────┼────────────┼─────────────┼──────────┘
          │              │            │             │
┌─────────┼──────────────┼────────────┼─────────────┼──────────┐
│ Docker  │              │            │             │          │
│         ▼              ▼            ▼             ▼          │
│  ┌─────────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │ The Machine │ │  Reese   │ │  Finch   │ │   Zoe    │   │
│  │ Coordinator │ │ Engineer │ │ Research │ │ Content  │   │
│  │ Grok 4.1    │ │ GLM-5    │ │ Grok 4.1 │ │ Grok 4.1 │   │
│  │ :42617      │ │ :42618   │ │ :42619   │ │ :42620   │   │
│  └──────┬──────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│         │              │            │             │          │
│         ▼              ▼            ▼             ▼          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Shared Volumes                          │   │
│  │  /workspace/projects  /workspace/shared              │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## Agent Roster

| Agent | Role | Model | Provider | Port |
|---|---|---|---|---|
| 🔴 **The Machine** | Coordinator & Task Routing | Grok 4.1 Fast | xAI | 42617 |
| 🔫 **Reese** | Software Engineer | GLM-5 | Z.AI | 42618 |
| 👔 **Finch** | Research & Intelligence | Grok 4.1 Fast | xAI | 42619 |
| 👠 **Zoe** | Content & Social Media | Grok 4.1 Fast | xAI | 42620 |

## Quick Start

```bash
# 1. Clone
git clone https://github.com/your-org/the-machine.git && cd the-machine

# 2. Configure
cp .env.example .env
# Edit .env with your API keys and Slack tokens

# 3. Build
docker compose build

# 4. Launch
docker compose up -d

# 5. Test — DM "The Machine" in Slack
# Send: status
```

See [docs/SETUP.md](docs/SETUP.md) for the full deployment guide and [docs/SLACK_SETUP.md](docs/SLACK_SETUP.md) for Slack app creation.

## How to Use

### Talk to The Machine (Coordinator)

DM The Machine to assign tasks. It routes to the right agent:

- *"Build me a REST API for user management"* → Routes to **Reese**
- *"Research the best auth libraries for Node.js"* → Routes to **Finch**
- *"Write a Twitter thread about our new feature"* → Routes to **Zoe**
- *"Squad status"* → Handled by **The Machine**

### Talk to Agents Directly

DM any agent directly for focused work:

- **Reese**: `scaffold my-app`, `fix the login bug`, `add rate limiting`
- **Finch**: `compare Prisma vs Drizzle`, `research WebSocket scaling`
- **Zoe**: `draft a blog post about AI agents`, `write release notes for v2.0`

### #machine-room

The coordination channel where agents collaborate. The Machine posts task assignments, agents report status.

## API Keys Required

| Key | Used By | Required |
|---|---|---|
| xAI API Key | Machine, Finch, Zoe | ✅ Yes |
| Z.AI API Key | Reese | ✅ Yes |
| Perplexity API Key | Finch | ⬜ Optional |
| GitHub Token | Reese | ⬜ Optional |

## Cost Estimate

Running all 4 agents on Oracle Cloud free tier:

| Component | Cost |
|---|---|
| Oracle Cloud VM (free tier) | $0/month |
| xAI API (3 agents, moderate use) | ~$5-10/month |
| Z.AI API (1 agent, moderate use) | ~$3-5/month |
| Perplexity API (optional) | ~$0-5/month |
| **Total** | **~$8-20/month** |

## Project Structure

```
the-machine/
├── Dockerfile.lean          # Lean image (Machine, Finch, Zoe)
├── Dockerfile.full          # Full image (Reese + Claude Code)
├── docker-compose.yml       # All 4 services
├── .env.example             # Environment template
├── scripts/
│   ├── entrypoint-lean.sh   # Grok agent entrypoint
│   ├── entrypoint-full.sh   # Reese entrypoint
│   └── build-handler.sh     # Gate-driven build system
├── agents/
│   ├── the-machine/         # Coordinator config + skills
│   ├── reese/               # Engineer config + skills
│   ├── finch/               # Researcher config + skills
│   └── zoe/                 # Content config + skills
├── docs/
│   ├── SETUP.md             # Deployment guide
│   └── SLACK_SETUP.md       # Slack app creation guide
└── README.md                # This file
```

## Operations

```bash
# View logs
docker compose logs -f              # All agents
docker compose logs -f the-machine  # Single agent

# Restart an agent
docker compose restart reese

# Stop everything
docker compose down

# Rebuild after changes
docker compose build && docker compose up -d

# Check health
docker compose ps
```

## Future Expansion

Planned agents for future squad expansion:

| Codename | Role | Notes |
|---|---|---|
| **Root** | Automation & Ops | CI/CD pipelines, infrastructure automation |
| **Shaw** | DevOps & Security | Container orchestration, security audits |
| **Fusco** | Monitoring & Alerts | System health, anomaly detection |

---

*"The machine never sleeps."*
