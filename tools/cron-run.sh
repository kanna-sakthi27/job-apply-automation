#!/usr/bin/env bash
# cron-run.sh <channel>  — run one job-application channel headlessly on Command Code.
#
#   * one browser at a time (flock mutex across all channels)
#   * free models first, in order; a paid model is only tried while the quota gate allows
#   * full log per run + Telegram report either way
#
# Channels: linkedin | indeed | glassdoor | jaabz |
#           foreign-canada | foreign-singapore | foreign-rotation
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
[ -f "$ROOT/.env" ] && set -a && . "$ROOT/.env" && set +a

CH="${1:-}"
if [ -z "$CH" ] || [ ! -f "$ROOT/prompts/$CH.md" ]; then
  echo "usage: cron-run.sh <channel>  (no prompt: prompts/${CH}.md)" >&2
  exit 2
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$ROOT/logs/${CH}-${STAMP}.log"
LOCK="/tmp/job-automation-browser.lock"
TIMEOUT="${APPLY_TIMEOUT_SECONDS:-2700}"
PER_MODEL="${APPLY_PER_MODEL_SECONDS:-1200}"
MAXTURNS="${APPLY_MAX_TURNS:-250}"
MODELS="${APPLY_MODELS:-poolside/laguna-s-2.1-free,inclusionai/ling-3.0-flash-sante:free,deepseek/deepseek-v4-flash}"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export HOME="${HOME:-$(getent passwd "$(id -u)" | cut -d: -f6)}"

mkdir -p "$ROOT/logs"
exec 9>"$LOCK"
say() { echo "[$(date '+%F %T')] $*"; }

# --- guard: exactly one browser run at a time -----------------------------
if ! flock -n 9; then
  say "SKIP $CH — another run holds the browser lock"
  say "skipped: another auto-apply run is in progress" | "$ROOT/tools/tg-notify.sh" >/dev/null 2>&1 || true
  exit 0
fi

say "run start channel=$CH models=$MODELS timeout=${TIMEOUT}s"
say "log=$LOG"

# --- pre-flight: is your Brave reachable over CDP? ---------------------
cdp_url() { curl -s --max-time 5 "http://127.0.0.1:${BRAVE_CDP_PORT:-9222}/json/version" 2>/dev/null; }
if [ -z "$(cdp_url)" ]; then
  say "Brave CDP not answering on ${BRAVE_CDP_PORT:-9222}; attempting relaunch"
  setsid env DISPLAY="${DISPLAY:-:0}" nohup brave-browser \
    --remote-debugging-port="${BRAVE_CDP_PORT:-9222}" --restore-last-session \
    >/tmp/brave-debug.log 2>&1 < /dev/null &
  for _ in $(seq 1 20); do sleep 3; [ -n "$(cdp_url)" ] && break; done
fi
if [ -z "$(cdp_url)" ]; then
  say "FATAL: Brave unavailable — aborting run"
  printf 'Job_Automation %s: FAILED — Brave not reachable on CDP %s (is it running?)\n' "$CH" "${BRAVE_CDP_PORT:-9222}" \
    | "$ROOT/tools/tg-notify.sh" >/dev/null 2>&1 || true
  exit 1
fi
say "Brave CDP OK"

# --- run, trying each free model in turn ----------------------------------
PROMPT="$(cat "$ROOT/prompts/$CH.md")"
RC=1; USED=""
START=$(date +%s)
IFS=',' read -ra ARR <<< "$MODELS"
for m in "${ARR[@]}"; do
  m="$(echo "$m" | xargs)"
  [ -n "$m" ] || continue

  # Free models ($0) always run. A paid model is only allowed while the quota gate says OK,
  # so a budget-exhausted week ends the run instead of spending.
  case "$m" in
    *:free|*-free) : ;;
    *)
      if ! "$ROOT/tools/cc-quota" --gate >/dev/null 2>&1; then
        say "quota gate BLOCKED paid fallback $m — not spending; stopping here"
        break
      fi
      say "paid fallback $m permitted by quota gate"
      ;;
  esac

  say "--- attempt model=$m ---"
  elapsed=$(( $(date +%s) - START ))
  remaining=$(( TIMEOUT - elapsed ))
  if [ "$remaining" -le 90 ]; then
    say "time budget exhausted ($elapsed/${TIMEOUT}s) — skipping $m"
    break
  fi
  # Cap each attempt so one throttled model can't eat the whole run's budget.
  attempt="$PER_MODEL"; [ "$attempt" -gt "$remaining" ] && attempt="$remaining"
  timeout "$attempt" cmd -p "$PROMPT" \
      --yolo --skip-onboarding --no-auto-update \
      --max-turns "$MAXTURNS" \
      --model "$m" >>"$LOG" 2>&1
  RC=$?
  USED="$m"
  [ "$RC" -eq 0 ] && { say "model=$m ok"; break; }
  if [ "$RC" -eq 8 ]; then
    # Turn cap, not a model failure: the run did real work (possibly submitted).
    # Retrying another model would redo the whole job — keep this result.
    say "model=$m hit the ${MAXTURNS}-turn cap (exit 8) — keeping its work, not retrying"
    break
  fi
  if [ "$RC" -eq 124 ]; then
    say "model=$m hit the ${attempt}s attempt cap — trying the next model"
  else
    say "model=$m failed rc=$RC"
  fi
done
DUR=$(( $(date +%s) - START ))

# --- report ---------------------------------------------------------------
case "$RC" in
  0) VERDICT="completed" ;;
  8) VERDICT="completed — hit the ${MAXTURNS}-turn cap (may be partial)" ;;
  *) VERDICT="FAILED (exit $RC)" ;;
esac
TAIL="$(tail -c 1200 "$LOG" 2>/dev/null)"
printf 'Job_Automation %s: %s\nmodel: %s · %ss\nlog: %s\n\n%s\n' \
  "$CH" "$VERDICT" "$USED" "$DUR" "$LOG" "$TAIL" | "$ROOT/tools/tg-notify.sh" >/dev/null 2>&1 || true
say "run end channel=$CH verdict=$VERDICT model=$USED duration=${DUR}s"
exit "$RC"
