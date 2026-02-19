#!/usr/bin/env bash
# rollbar.sh — Rollbar API helper for OpenClaw
# Usage: rollbar.sh <command> [options]

set -euo pipefail

# --- Config ---
TOKEN="${ROLLBAR_ACCESS_TOKEN:-}"
BASE_URL="https://api.rollbar.com/api/1"

if [[ -z "$TOKEN" ]]; then
  echo "Error: ROLLBAR_ACCESS_TOKEN is not set." >&2
  echo "Set it via environment variable or add it to TOOLS.md." >&2
  exit 1
fi

# --- Helpers ---
api_get() {
  local endpoint="$1"
  shift
  curl -sf -H "X-Rollbar-Access-Token: $TOKEN" "$BASE_URL/$endpoint" "$@"
}

api_patch() {
  local endpoint="$1"
  local data="$2"
  curl -sf -X PATCH \
    -H "X-Rollbar-Access-Token: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data" \
    "$BASE_URL/$endpoint"
}

usage() {
  cat <<EOF
Usage: rollbar.sh <command> [options]

Commands:
  items         List recent items
  item <id>     Get item details
  occurrences <id>  Get occurrences for an item
  resolve <id>  Resolve an item
  mute <id>     Mute an item
  activate <id> Reopen an item
  deploys       List recent deploys
  project       Get project info
  top           Top active items by occurrence count

Options:
  --status <active|resolved|muted>   Filter by status (items)
  --level <critical|error|warning|info>  Filter by level (items)
  --limit <n>                        Max results (default: 20)
  --hours <n>                        Time window for 'top' (default: 24)

Environment:
  ROLLBAR_ACCESS_TOKEN   Required. Your Rollbar project access token.
EOF
  exit 0
}

# --- Parse command ---
COMMAND="${1:-}"
[[ -z "$COMMAND" || "$COMMAND" == "--help" || "$COMMAND" == "-h" ]] && usage
shift

# --- Parse options ---
STATUS=""
LEVEL=""
LIMIT="20"
HOURS="24"
ITEM_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)  STATUS="$2"; shift 2 ;;
    --level)   LEVEL="$2"; shift 2 ;;
    --limit)   LIMIT="$2"; shift 2 ;;
    --hours)   HOURS="$2"; shift 2 ;;
    *)
      if [[ -z "$ITEM_ID" ]]; then
        ITEM_ID="$1"; shift
      else
        echo "Unknown option: $1" >&2; exit 1
      fi
      ;;
  esac
done

# --- Commands ---
case "$COMMAND" in
  items)
    PARAMS="?page=1&sort=last_occurrence"
    [[ -n "$STATUS" ]] && PARAMS="$PARAMS&status=$STATUS"
    [[ -n "$LEVEL" ]] && PARAMS="$PARAMS&level=$LEVEL"
    api_get "items$PARAMS" | python3 -m json.tool 2>/dev/null || api_get "items$PARAMS"
    ;;

  item)
    [[ -z "$ITEM_ID" ]] && { echo "Usage: rollbar.sh item <item_id>" >&2; exit 1; }
    api_get "item/$ITEM_ID" | python3 -m json.tool 2>/dev/null || api_get "item/$ITEM_ID"
    ;;

  occurrences)
    [[ -z "$ITEM_ID" ]] && { echo "Usage: rollbar.sh occurrences <item_id>" >&2; exit 1; }
    api_get "item/$ITEM_ID/instances/?page=1" | python3 -m json.tool 2>/dev/null || api_get "item/$ITEM_ID/instances/?page=1"
    ;;

  resolve)
    [[ -z "$ITEM_ID" ]] && { echo "Usage: rollbar.sh resolve <item_id>" >&2; exit 1; }
    api_patch "item/$ITEM_ID" '{"status":"resolved"}' | python3 -m json.tool 2>/dev/null || api_patch "item/$ITEM_ID" '{"status":"resolved"}'
    ;;

  mute)
    [[ -z "$ITEM_ID" ]] && { echo "Usage: rollbar.sh mute <item_id>" >&2; exit 1; }
    api_patch "item/$ITEM_ID" '{"status":"muted"}' | python3 -m json.tool 2>/dev/null || api_patch "item/$ITEM_ID" '{"status":"muted"}'
    ;;

  activate)
    [[ -z "$ITEM_ID" ]] && { echo "Usage: rollbar.sh activate <item_id>" >&2; exit 1; }
    api_patch "item/$ITEM_ID" '{"status":"active"}' | python3 -m json.tool 2>/dev/null || api_patch "item/$ITEM_ID" '{"status":"active"}'
    ;;

  deploys)
    api_get "deploys/?page=1" | python3 -m json.tool 2>/dev/null || api_get "deploys/?page=1"
    ;;

  project)
    api_get "project" | python3 -m json.tool 2>/dev/null || api_get "project"
    ;;

  top)
    # Get active items sorted by total_occurrences, filter by time window
    PARAMS="?status=active&sort=total_occurrences&direction=desc&page=1"
    [[ -n "$LEVEL" ]] && PARAMS="$PARAMS&level=$LEVEL"
    api_get "items$PARAMS" | python3 -c "
import json, sys
from datetime import datetime, timedelta, timezone

data = json.load(sys.stdin)
items = data.get('result', {}).get('items', data.get('result', []))
hours = $HOURS
cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)

print(json.dumps({
    'window_hours': hours,
    'items': [{
        'id': i['id'],
        'counter': i.get('counter'),
        'title': i.get('title', '')[:120],
        'level': i.get('level_string', i.get('level', '')),
        'total_occurrences': i.get('total_occurrences', 0),
        'last_occurrence': i.get('last_occurrence_timestamp'),
        'environment': i.get('environment', ''),
    } for i in (items if isinstance(items, list) else [])
      if i.get('last_occurrence_timestamp', 0) >= cutoff.timestamp()
    ][:int('$LIMIT')]
}, indent=2))
" 2>/dev/null || api_get "items$PARAMS"
    ;;

  *)
    echo "Unknown command: $COMMAND" >&2
    usage
    ;;
esac
