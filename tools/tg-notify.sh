#!/usr/bin/env bash
# Send a Telegram message to the configured chat. Text on stdin (or $1). Never fails the caller.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$HERE/.env" ] && set -a && . "$HERE/.env" && set +a
: "${TELEGRAM_BOT_TOKEN:?TELEGRAM_BOT_TOKEN missing}"
: "${TELEGRAM_CHAT_ID:?TELEGRAM_CHAT_ID missing}"

TEXT="${1-$(cat)}"
[ -n "$TEXT" ] || exit 0
# Telegram caps messages at 4096 chars.
TEXT="${TEXT:0:4000}"

resp=$(curl -s --max-time 25 -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${TEXT}" 2>&1) || true

case "$resp" in
  *'"ok":true'*) echo "telegram: sent" ;;
  *) echo "telegram: FAILED ($resp)" >&2; exit 1 ;;
esac
