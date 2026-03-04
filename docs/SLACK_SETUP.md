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

### Reese, Finch, Zoe (Operatives) — Reduced Scopes

These agents should **only** respond when @mentioned or DMed.

| Scope | Purpose |
|---|---|
| `chat:write` | Send messages |
| `app_mentions:read` | Respond to @mentions |
| `channels:read` | See channel list |
| `im:history` | Read DM history |
| `im:read` | See DMs |
| `im:write` | Send DMs |
| `groups:read` | See private channels |
| `mpim:read` | See group DMs (required for channel discovery) |
| `canvases:read` | Read canvas content |
| `canvases:write` | Create and edit canvases |
| `reactions:read` | See emoji reactions (for gate approvals) |
| `reactions:write` | Add emoji reactions |

⚠️ Do **NOT** add `channels:history` or `groups:history` to operatives — they don't need to read all channel messages.

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

⚠️ Do **NOT** add `message.channels` or `message.groups` — these cause operatives to respond to every channel message.

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

Sample Manifests:

### The Machine (Coordinator)

```yaml
display_information:
  name: The Machine
  description: Coordinator & Task Routing
  background_color: "#000000"
features:
  bot_user:
    display_name: The Machine
    always_online: true
oauth_config:
  scopes:
    bot:
      - app_mentions:read
      - canvases:read
      - canvases:write
      - channels:history
      - channels:read
      - chat:write
      - groups:history
      - groups:read
      - im:history
      - im:read
      - im:write
      - mpim:read
      - reactions:read
      - reactions:write
settings:
  event_subscriptions:
    bot_events:
      - app_mention
      - message.channels
      - message.groups
      - message.im
      - reaction_added
  interactivity:
    is_enabled: true
  org_deploy_enabled: false
  socket_mode_enabled: true
  token_rotation_enabled: false
```

### Reese (Software Engineer)

```yaml
display_information:
  name: Reese
  description: Software Engineer
  background_color: "#000000"
features:
  bot_user:
    display_name: Reese
    always_online: true
oauth_config:
  scopes:
    bot:
      - app_mentions:read
      - canvases:read
      - canvases:write
      - channels:read
      - chat:write
      - groups:read
      - im:history
      - im:read
      - im:write
      - mpim:read
      - reactions:read
      - reactions:write
settings:
  event_subscriptions:
    bot_events:
      - app_mention
      - message.im
      - reaction_added
  interactivity:
    is_enabled: true
  org_deploy_enabled: false
  socket_mode_enabled: true
  token_rotation_enabled: false
```

### Finch (Research & Intelligence)

```yaml
display_information:
  name: Finch
  description: Research & Intelligence
  background_color: "#000000"
features:
  bot_user:
    display_name: Finch
    always_online: true
oauth_config:
  scopes:
    bot:
      - app_mentions:read
      - canvases:read
      - canvases:write
      - channels:read
      - chat:write
      - groups:read
      - im:history
      - im:read
      - im:write
      - mpim:read
      - reactions:read
      - reactions:write
settings:
  event_subscriptions:
    bot_events:
      - app_mention
      - message.im
      - reaction_added
  interactivity:
    is_enabled: true
  org_deploy_enabled: false
  socket_mode_enabled: true
  token_rotation_enabled: false
```

### Zoe (Content & Social Media)

```yaml
display_information:
  name: Zoe
  description: Content & Social Media
  background_color: "#000000"
features:
  bot_user:
    display_name: Zoe
    always_online: true
oauth_config:
  scopes:
    bot:
      - app_mentions:read
      - canvases:read
      - canvases:write
      - channels:read
      - chat:write
      - groups:read
      - im:history
      - im:read
      - im:write
      - mpim:read
      - reactions:read
      - reactions:write
settings:
  event_subscriptions:
    bot_events:
      - app_mention
      - message.im
      - reaction_added
  interactivity:
    is_enabled: true
  org_deploy_enabled: false
  socket_mode_enabled: true
  token_rotation_enabled: false
```