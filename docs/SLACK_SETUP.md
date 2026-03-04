# Slack Setup Guide — The Machine

How to create 4 Slack apps for the multi-agent squad.

## Overview

Each agent is a **separate Slack app** with its own bot token and app-level token. You need to create 4 apps:

| App Name | Agent | Purpose |
|---|---|---|
| The Machine | Coordinator | Task routing, status |
| Reese | Engineer | Software engineering |
| Finch | Researcher | Research & intelligence |
| Zoe | Content | Content & social media |

## Step 1: Create a Slack App

1. Go to https://api.slack.com/apps
2. Click **Create New App** → **From scratch**
3. Name: `The Machine` (or `Reese`, `Finch`, `Zoe`)
4. Select your workspace
5. Click **Create App**

**Repeat this for all 4 agents.**

## Step 2: Configure Bot Token Scopes

> **Important**: The Machine (coordinator) needs broader scopes than the other agents.
> Reese, Finch, and Zoe should only respond to @mentions and DMs — NOT to every channel message.

### The Machine (Coordinator) — Full Scopes

1. Go to **OAuth & Permissions** (sidebar)
2. Scroll to **Scopes** → **Bot Token Scopes**
3. Add these scopes:

| Scope | Purpose |
|---|---|
| `chat:write` | Send messages |
| `app_mentions:read` | Respond to @mentions |
| `channels:history` | Read public channel messages |
| `channels:read` | See channel list |
| `im:history` | Read DM history |
| `im:read` | See DMs |
| `im:write` | Send DMs |
| `groups:history` | Read private channel messages |
| `groups:read` | See private channels |
| `mpim:read` | See group DMs (required for channel discovery) |
| `canvases:read` | Read canvas content |
| `canvases:write` | Create and edit canvases |
| `reactions:read` | See emoji reactions (for gate approvals) |
| `reactions:write` | Add emoji reactions |

### Reese, Finch, Zoe (Operatives) — Thread-Aware Scopes

These agents respond to @mentions, DMs, and **thread replies** in conversations they're participating in.

| Scope | Purpose |
|---|---|
| `chat:write` | Send messages |
| `app_mentions:read` | Respond to @mentions |
| `channels:history` | Read channel messages (needed for thread replies) |
| `channels:read` | See channel list |
| `im:history` | Read DM history |
| `im:read` | See DMs |
| `im:write` | Send DMs |
| `groups:history` | Read private channel messages (needed for thread replies) |
| `groups:read` | See private channels |
| `mpim:read` | See group DMs (required for channel discovery) |
| `canvases:read` | Read canvas content |
| `canvases:write` | Create and edit canvases |
| `reactions:read` | See emoji reactions (for gate approvals) |
| `reactions:write` | Add emoji reactions |

> **Note**: `channels:history` and `groups:history` are needed so operatives can detect thread replies. Their identity instructions strictly limit them to only respond in threads they're participating in — they will NOT respond to random channel messages.

## Step 3: Enable Socket Mode

For each app:

1. Go to **Settings** → **Socket Mode** (sidebar)
2. Toggle **Enable Socket Mode** → On
3. When prompted, create an **App-Level Token**:
   - Token Name: `socket-mode` (or any name)
   - Scope: `connections:write`
   - Click **Generate**
4. **Copy the App-Level Token** (starts with `xapp-`) — save it for `.env`

## Step 4: Enable Event Subscriptions

> **Important**: Different event subscriptions for coordinator vs operatives.

### The Machine (Coordinator)

1. Go to **Event Subscriptions** (sidebar)
2. Toggle **Enable Events** → On
3. Under **Subscribe to bot events**, add:

| Event | Purpose |
|---|---|
| `message.im` | Receive DMs |
| `app_mention` | Respond to @mentions in channels |
| `message.channels` | See all messages in public channels |
| `message.groups` | See all messages in private channels |

4. Click **Save Changes**

### Reese, Finch, Zoe (Operatives)

1. Go to **Event Subscriptions** (sidebar)
2. Toggle **Enable Events** → On
3. Under **Subscribe to bot events**, add:

| Event | Purpose |
|---|---|
| `message.im` | Receive DMs |
| `app_mention` | Respond to @mentions in channels |
| `message.channels` | Detect thread replies in public channels |
| `message.groups` | Detect thread replies in private channels |

> **Note**: Operatives now receive all channel messages, but their identity instructions strictly enforce: **only respond to @mentions, DMs, and thread replies to messages they sent**. They will ignore all other channel traffic.

4. Click **Save Changes**

## Step 5: Install to Workspace

For each app:

1. Go to **OAuth & Permissions** (sidebar)
2. Click **Install to Workspace**
3. Authorize the app
4. **Copy the Bot Token** (starts with `xoxb-`) — save it for `.env`

## Step 6: Collect Your Tokens

After creating all 4 apps, you should have:

```
# The Machine
MACHINE_SLACK_BOT_TOKEN=xoxb-...  (from OAuth & Permissions)
MACHINE_SLACK_APP_TOKEN=xapp-...  (from Socket Mode)

# Reese
REESE_SLACK_BOT_TOKEN=xoxb-...
REESE_SLACK_APP_TOKEN=xapp-...

# Finch
FINCH_SLACK_BOT_TOKEN=xoxb-...
FINCH_SLACK_APP_TOKEN=xapp-...

# Zoe
ZOE_SLACK_BOT_TOKEN=xoxb-...
ZOE_SLACK_APP_TOKEN=xapp-...
```

## Step 7: Get Your Slack Member ID

1. Open Slack
2. Click on your **profile picture** (bottom-left)
3. Click **Profile**
4. Click the **⋮** (three dots) menu
5. Click **Copy member ID**

This is your `SLACK_USER_ID` (starts with `U`).

## Step 8: Create #machine-room Channel

1. In Slack, create a new channel called `#machine-room`
2. Make it **private** (recommended) or public
3. Invite all 4 bots:
   - `/invite @The Machine`
   - `/invite @Reese`
   - `/invite @Finch`
   - `/invite @Zoe`

## Step 9: Add Agents to Relevant Channels (Optional)

Add individual agents to channels where they can be useful:

- `/invite @Reese` → `#engineering`, `#dev`
- `/invite @Finch` → `#research`, `#strategy`
- `/invite @Zoe` → `#content`, `#marketing`

Agents will see messages in these channels and respond when mentioned or when the message is relevant to their role.

## Tips

- **Customize app icons**: Upload Person of Interest -themed avatars for each agent at **Settings** → **Basic Information** → **Display Information**
- **App descriptions**: Add descriptions so team members know what each bot does
- **Reinstall after scope changes**: If you add new scopes, you need to reinstall the app to your workspace

## App Manifests

Each agent has a ready-to-use Slack app manifest at:

```
agents/the-machine/config/slack-app-manifest.yaml   # The Machine (Coordinator)
agents/reese/config/slack-app-manifest.yaml          # Reese (Software Engineer)
agents/finch/config/slack-app-manifest.yaml          # Finch (Research & Intelligence)
agents/zoe/config/slack-app-manifest.yaml            # Zoe (Content & Social Media)
```

To use a manifest: Go to https://api.slack.com/apps → **Create New App** → **From an app manifest** → paste the YAML content.