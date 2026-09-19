#!/usr/bin/env bash
# cron-run.sh <channel>  — run one job-application channel headlessly on Command Code.
#
#   * one browser at a time (flock mutex across all channels)
#   * zero-token pre-flight: browser up? logged in? budget left? what is already applied?
#   * one session per run — a model switch or a turn-cap hit RESUMES it instead of redoing the work
#   * free models first, in order; a paid model is only tried while the quota gate allows
#   * full log per run + Telegram report either way
#
# Channels are declared in config/channels.conf — this launcher is channel-agnostic:
# it runs whatever `prompts/<channel>.md` exists. Add one with tools/new-channel.sh.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
[ -f "$ROOT/.env" ] && set -a && . "$ROOT/.env" && set +a

CH="${1:-}"
DRY_RUN=0
[ "${2:-}" = "--dry-run" ] && DRY_RUN=1
if [ -z "$CH" ] || [ ! -f "$ROOT/prompts/$CH.md" ]; then
  echo "usage: cron-run.sh <channel> [--dry-run]  (no prompt: prompts/${CH}.md)" >&2
  exit 2
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$ROOT/logs/${CH}-${STAMP}.log"
LOCK="/tmp/job-automation-browser.lock"
TIMEOUT="${APPLY_TIMEOUT_SECONDS:-2700}"
PER_MODEL="${APPLY_PER_MODEL_SECONDS:-1200}"
FIRST_MODEL_CAP="${APPLY_FIRST_MODEL_SECONDS:-600}"
MAXTURNS="${APPLY_MAX_TURNS:-250}"
MODELS="${APPLY_MODELS:-poolside/laguna-s-2.1-free,inclusionai/ling-3.0-flash-sante:free,deepseek/deepseek-v4-flash}"
SESSION="apply-$CH-$STAMP"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export HOME="${HOME:-$(getent passwd "$(id -u)" | cut -d: -f6)}"

SLUG="$(printf '%s' "$ROOT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/^-\+//; s/-\+$//')"
PROJ="$HOME/.commandcode/projects/$SLUG"

mkdir -p "$ROOT/logs"
exec 9>"$LOCK"
say() { echo "[$(date '+%F %T')] $*"; }
# the selftest channel exists to exercise the launcher, so it must never message the candidate
notify() { if [ "$CH" = selftest ]; then cat >/dev/null; return 0; fi; "$ROOT/tools/tg-notify.sh"; }

# --- guard: exactly one browser run at a time -----------------------------
if ! flock -n 9; then
  say "SKIP $CH — another run holds the browser lock"
  say "skipped: another auto-apply run is in progress" | notify >/dev/null 2>&1 || true
  exit 0
fi

say "run start channel=$CH models=$MODELS timeout=${TIMEOUT}s maxturns=$MAXTURNS"
say "log=$LOG session=$SESSION"

# --- pre-flight (shell only, no model tokens) -----------------------------
PREFLIGHT_FILE="$ROOT/logs/.preflight-$CH-$STAMP.md"
PREFLIGHT_ERR="$ROOT/logs/.preflight-$CH-$STAMP.err"
"$ROOT/tools/apply-preflight.sh" "$CH" >"$PREFLIGHT_FILE" 2>"$PREFLIGHT_ERR"
PFRC=$?
if [ "$PFRC" -ne 0 ]; then
  reason="$(head -3 "$PREFLIGHT_ERR" 2>/dev/null)"
  say "PREFLIGHT blocked (exit $PFRC): $reason"
  if [ "$DRY_RUN" = 1 ]; then
    cat "$PREFLIGHT_FILE" 2>/dev/null
    rm -f "$PREFLIGHT_ERR"
    exit 3
  fi
  { echo "Job_Automation $CH: BLOCKED before starting (no model spend)."; echo; cat "$PREFLIGHT_FILE" 2>/dev/null; echo; echo "$reason"; } \
    | notify >/dev/null 2>&1 || true
  cp "$PREFLIGHT_FILE" "$LOG" 2>/dev/null || true
  rm -f "$PREFLIGHT_ERR"
  exit 3
fi
rm -f "$PREFLIGHT_ERR"
say "preflight OK (budget/session/dedupe digest built)"

# --- compose the prompt: shared preamble + preflight digest + channel body --
PROMPT="$(cat "$ROOT/prompts/_shared.md" "$PREFLIGHT_FILE" "$ROOT/prompts/$CH.md")"
CONTINUE_PROMPT="Continue this run from exactly where you left off — the browser is still on the page you were working on. Do not re-read any file you have already read. Pick up the next unfinished job and carry it to submit. Finish with the short Telegram report and stop."

touch "$ROOT/logs/.run-marker"
marker="$ROOT/logs/.run-marker"

session_exists() { # did this run create a session transcript yet?
  [ -d "$PROJ" ] && [ -n "$(find "$PROJ" -name '*.jsonl' -newer "$marker" -print -quit 2>/dev/null)" ]
}

if [ "$DRY_RUN" = 1 ]; then
  echo "--- dry run: $CH ---"
  echo "prompt bytes : $(printf '%s' "$PROMPT" | wc -c)  (was ~110 KB when it read the bank + ruleset)"
  echo "models       : $MODELS"
  echo "caps         : first=${FIRST_MODEL_CAP}s others=${PER_MODEL}s total=${TIMEOUT}s turns=${MAXTURNS}"
  echo "session name : $SESSION"
  echo "preflight    : $(head -c 200 "$PREFLIGHT_FILE")"
  echo "command      : cmd -p <prompt> --yolo --skip-onboarding --no-auto-update --max-turns $MAXTURNS -n $SESSION --model <first model>"
  echo "no model was invoked, nothing was sent."
  rm -f "$PREFLIGHT_ERR"
  exit 0
fi

# --- run: first model fresh, every retry RESUMES the same session ---------
RC=1; USED=""
START=$(date +%s)
IFS=',' read -ra ARR <<< "$MODELS"
i=0
while [ "$i" -lt "${#ARR[@]}" ]; do
  m="$(echo "${ARR[$i]}" | xargs)"; i=$((i+1))
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

  elapsed=$(( $(date +%s) - START ))
  remaining=$(( TIMEOUT - elapsed ))
  if [ "$remaining" -le 90 ]; then
    say "time budget exhausted ($elapsed/${TIMEOUT}s) — skipping $m"
    break
  fi
  # First model gets a short leash so a throttled free model cannot eat the whole run;
  # later (usually the paid) models get the longer cap.
  attempt="$PER_MODEL"
  [ "$i" -eq 1 ] && attempt="$FIRST_MODEL_CAP"
  [ "$attempt" -gt "$remaining" ] && attempt="$remaining"

  if [ -n "$USED" ] || session_exists; then
    # Resume the SAME session so the new model inherits everything already done.
    say "--- resume model=$m (cap ${attempt}s) ---"
    timeout "$attempt" cmd -p "$CONTINUE_PROMPT" \
        --resume "$SESSION" --yolo --skip-onboarding --no-auto-update \
        --max-turns "$MAXTURNS" \
        --model "$m" >>"$LOG" 2>&1
    RC=$?
    if [ "$RC" -ne 0 ] && [ "$RC" -ne 8 ] && [ "$RC" -ne 124 ]; then
      # Resume itself may have failed — fall back to a clean start on this model.
      say "resume failed rc=$RC — starting fresh on $m"
      timeout "$attempt" cmd -p "$PROMPT" \
          --yolo --skip-onboarding --no-auto-update \
          --max-turns "$MAXTURNS" \
          -n "$SESSION" --model "$m" >>"$LOG" 2>&1
      RC=$?
    fi
  else
    say "--- attempt model=$m (fresh, cap ${attempt}s) ---"
    timeout "$attempt" cmd -p "$PROMPT" \
        --yolo --skip-onboarding --no-auto-update \
        --max-turns "$MAXTURNS" \
        -n "$SESSION" --model "$m" >>"$LOG" 2>&1
    RC=$?
  fi
  USED="$m"

  [ "$RC" -eq 0 ] && { say "model=$m ok"; break; }
  if [ "$RC" -eq 8 ]; then
    # Turn cap, not a failure: the run did real work. Resume once to finish the job rather than
    # throwing that work away — but only while the run budget still allows it.
    if [ $(( $(date +%s) - START )) -lt $(( TIMEOUT - 300 )) ]; then
      say "model=$m hit the ${MAXTURNS}-turn cap — resuming the same session to finish"
      ARR+=("$m")
    else
      say "model=$m hit the ${MAXTURNS}-turn cap and the time budget is spent — stopping"
      break
    fi
  elif [ "$RC" -eq 124 ]; then
    say "model=$m hit the ${attempt}s attempt cap — trying the next model"
  else
    say "model=$m failed rc=$RC"
  fi
done
DUR=$(( $(date +%s) - START ))

# --- token accounting for this run ---------------------------------------
STATS="$("$ROOT/tools/run-stats.sh" --window "$START" "$(date +%s)" 2>/dev/null | tail -4)"
[ -n "$STATS" ] && { echo "$STATS" >>"$LOG"; say "stats: $(echo "$STATS" | tr '\n' ' ')"; }

# --- report ---------------------------------------------------------------
case "$RC" in
  0) VERDICT="completed" ;;
  8) VERDICT="completed — hit the ${MAXTURNS}-turn cap (may be partial)" ;;
  *) VERDICT="FAILED (exit $RC)" ;;
esac
TAIL="$(tail -c 1200 "$LOG" 2>/dev/null)"
printf 'Job_Automation %s: %s\nmodel: %s · %ss\n\n%s\n\n--- tokens ---\n%s\nlog: %s\n' \
  "$CH" "$VERDICT" "$USED" "$DUR" "$TAIL" "$STATS" "$LOG" | notify >/dev/null 2>&1 || true
say "run end channel=$CH verdict=$VERDICT model=$USED duration=${DUR}s"
exit "$RC"
