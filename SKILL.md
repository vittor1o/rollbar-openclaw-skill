---
name: rollbar
description: "Monitor and manage Rollbar error tracking. List recent items, get item details, resolve/mute issues, and track deployments via the Rollbar API."
homepage: https://github.com/vittor1o/rollbar-openclaw-skill
metadata:
  openclaw:
    emoji: "🐛"
---

# Rollbar Skill

Monitor and manage Rollbar errors directly from OpenClaw.

## Setup

Set your Rollbar access token as an environment variable:

```bash
export ROLLBAR_ACCESS_TOKEN=your-token
```

**Two token types are supported:**

- **Account-level token** (recommended for multi-project setups) — found in Rollbar → Account Settings → Account Access Tokens. Use `--project-id <id>` to target specific projects. The skill auto-resolves a project read token from the account token.
- **Project-level token** — found in Rollbar → Project → Settings → Project Access Tokens (use one with `read` scope; add `write` scope to resolve/mute items).

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
