# Rollbar Skill for OpenClaw

🐛 Monitor and manage [Rollbar](https://rollbar.com) error tracking directly from [OpenClaw](https://openclaw.ai).

## Features

- **List & filter** active errors by status and severity level
- **Inspect** item details and individual occurrences
- **Triage** — resolve, mute, or reopen items
- **Deployments** — list recent deploys
- **Top errors** — rank active items by occurrence count within a time window
- **Proactive monitoring** — pair with OpenClaw cron for automatic alerts

## Installation

```bash
clawhub install rollbar
```

Or manually clone this repo into your OpenClaw workspace `skills/` directory.

## Setup

Set your Rollbar project access token:

```bash
export ROLLBAR_ACCESS_TOKEN=your-token-here
```

Find your token in Rollbar → Project → Settings → Project Access Tokens. Use a token with `read` scope (add `write` if you want to resolve/mute items).

## Usage

```bash
# List active errors
./skills/rollbar/rollbar.sh items --status active --level error

# Get item details
./skills/rollbar/rollbar.sh item 12345

# Top errors in the last 24 hours
./skills/rollbar/rollbar.sh top --hours 24

# Resolve an item
./skills/rollbar/rollbar.sh resolve 12345

# List deploys
./skills/rollbar/rollbar.sh deploys
```

See [SKILL.md](./SKILL.md) for full command reference.

## Proactive Monitoring

Set up an OpenClaw cron job to check for new errors automatically:

> "Check Rollbar for new critical or error-level items in the last hour. Summarize and alert me if any new items appeared."

## License

MIT
