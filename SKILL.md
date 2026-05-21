---
name: rollbar
version: 1.3.0
description: "Monitor and manage Rollbar error tracking. List recent items, get item details, resolve/mute issues, and track deployments via the Rollbar API."
homepage: https://github.com/vittor1o/rollbar-openclaw-skill
metadata:
  openclaw:
    emoji: "🐛"
    requires:
      bins:
        - curl
        - python3
---

# Rollbar Skill

Monitor and manage Rollbar errors directly from OpenClaw.

## Setup

The script resolves your Rollbar token from the first matching source:

| Priority | Method | How |
|---|---|---|
| 1 | `$PWD/secrets/rollbar` | One-line file in your agent workspace containing the token |
| 2 | `$PWD/.env` | File in your agent workspace with `ROLLBAR_ACCESS_TOKEN=your-token` |
| 3 | `ROLLBAR_ACCESS_TOKEN` | Environment variable (injected or shell) |

**Recommended for most agents — use a `.env` file in your workspace:**

```bash
# workspace-myagent/.env
ROLLBAR_ACCESS_TOKEN=your-token-here
```

**Or use a dedicated secrets file:**

```bash
# workspace-myagent/secrets/rollbar  (one line)
your-token-here
```

> **⚠️ Security:** Never commit tokens to the skill repository. Use workspace-local files (`.env`, `secrets/`) or environment variables only.

**Token types:**

- **Project-level token** (recommended) — found in Rollbar → Project → Settings → Project Access Tokens. Use a token with `read` scope for monitoring; add `write` scope only if you need to resolve/mute items. This is the most restrictive and safest option for single-project use.
- **Account-level token** (for multi-project setups) — found in Rollbar → Account Settings → Account Access Tokens. Use `--project-id <id>` to target specific projects. The skill auto-resolves a project read token from the account token. Note: account tokens grant broader access — only use when you need to monitor multiple projects.

## Commands

All commands use the helper script `rollbar.sh` in this skill directory.

### List projects (account token only)

```bash
./skills/rollbar/rollbar.sh projects
```

### List recent items (errors/warnings)

```bash
./skills/rollbar/rollbar.sh items [--project-id <id>] [--status active|resolved|muted] [--level critical|error|warning|info] [--limit 20]
```

### Get item details

```bash
./skills/rollbar/rollbar.sh item <item_id>
```

### Get occurrences for an item

```bash
./skills/rollbar/rollbar.sh occurrences <item_id> [--limit 5]
```

### Resolve an item

```bash
./skills/rollbar/rollbar.sh resolve <item_id>
```

### Mute an item

```bash
./skills/rollbar/rollbar.sh mute <item_id>
```

### Activate (reopen) an item

```bash
./skills/rollbar/rollbar.sh activate <item_id>
```

### List deploys

```bash
./skills/rollbar/rollbar.sh deploys [--limit 10]
```

### Get project info

```bash
./skills/rollbar/rollbar.sh project
```

### Top active items (summary)

```bash
./skills/rollbar/rollbar.sh top [--limit 10] [--hours 24]
```

## Proactive Monitoring

To get automatic alerts for new critical/error items, set up a cron job in OpenClaw:

> "Check Rollbar for new critical or error-level items in the last hour. If any new items appeared, summarize them and alert me."

Recommended schedule: every 30–60 minutes during work hours.

## Notes

- All output is JSON for easy parsing.
- The `top` command sorts active items by occurrence count — useful for daily triage.
- Rollbar API docs: https://docs.rollbar.com/reference
