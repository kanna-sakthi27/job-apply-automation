#!/usr/bin/env bash
# install-cron.sh — turn config/channels.conf into crontab lines.
#
#   install-cron.sh            install/refresh the managed block in your crontab
#   install-cron.sh --dry-run  print the lines instead of installing
#   install-cron.sh --remove   remove the managed block, leaving everything else alone
#
# Only lines between the markers below are touched. Anything else already in your crontab is
# preserved byte for byte — this never rewrites a crontab it does not own.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$ROOT/config/channels.conf"
LAUNCHER="$ROOT/tools/cron-run.sh"
LOG="$ROOT/logs/cron.log"
BEGIN="# >>> job-apply-automation (managed by tools/install-cron.sh) >>>"
END="# <<< job-apply-automation <<<"

MODE="install"
case "${1:-}" in
  --dry-run) MODE="dry" ;;
  --remove)  MODE="remove" ;;
  "")        MODE="install" ;;
  *) echo "usage: install-cron.sh [--dry-run|--remove]" >&2; exit 2 ;;
esac

[ -f "$CONF" ] || { echo "missing $CONF" >&2; exit 2; }
[ -x "$LAUNCHER" ] || { echo "missing or not executable: $LAUNCHER" >&2; exit 2; }

trim() { local s="${1:-}"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }

build_block() {
  echo "$BEGIN"
  echo "SHELL=/bin/bash"
  echo "PATH=/usr/local/bin:/usr/bin:/bin"
  echo "# generated from config/channels.conf — edit that file, then re-run tools/install-cron.sh"
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    name="$(trim "$(printf '%s' "$line" | cut -d'|' -f1)")"
    enabled="$(trim "$(printf '%s' "$line" | cut -d'|' -f2)")"
    sched="$(trim "$(printf '%s' "$line" | cut -d'|' -f3)")"
    [ "$name" = "*" ] && continue
    [ "$enabled" = "yes" ] || continue
    [ "$sched" = "-" ] && continue
    [ -n "$sched" ] || continue
    printf '%s %s %s >> %s 2>&1\n' "$sched" "$LAUNCHER" "$name" "$LOG"
  done < "$CONF"
  echo "$END"
}

strip_block() { # stdin -> stdout, managed block removed
  awk -v b="$BEGIN" -v e="$END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  '
}

NEW_BLOCK="$(build_block)"

case "$MODE" in
  dry)
    echo "$NEW_BLOCK"
    echo
    echo "(dry run — nothing installed)"
    exit 0
    ;;
  remove)
    if ! crontab -l >/dev/null 2>&1; then echo "no crontab to remove from"; exit 0; fi
    TMP="$(mktemp)"; crontab -l | strip_block > "$TMP"
    crontab "$TMP" && echo "removed the job-apply-automation block"; rm -f "$TMP"
    exit 0
    ;;
esac

TMP="$(mktemp)"
{ crontab -l 2>/dev/null | strip_block; echo "$NEW_BLOCK"; } > "$TMP"

# drop the blank-line buildup the strip can leave at the top
sed -i '/./,$!d' "$TMP" 2>/dev/null || true

if ! crontab "$TMP"; then
  echo "failed to install crontab" >&2; rm -f "$TMP"; exit 1
fi
rm -f "$TMP"

echo "installed:"
echo "$NEW_BLOCK" | grep -v '^#' | grep -v '^$' | sed 's/^/  /'
echo
echo "verify with: crontab -l   ·   tools/jobs-status.sh"
