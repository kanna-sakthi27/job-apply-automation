#!/usr/bin/env bash
# apply-preflight.sh <channel> [--no-login-probe]
#
# Zero-token pre-flight for one job-apply channel. Runs BEFORE the model starts, so anything it
# catches costs nothing instead of a 45-minute run.
#
#   stdout : a PREFLIGHT markdown block that cron-run.sh appends to the channel prompt
#            (today's count / remaining budget / already-applied digest / session state)
#   exit 0 : go
#   exit 3 : BLOCKED — do not start the model; the reason goes to stderr
#   exit 2 : usage / bad config
#
# Everything here is shell only. No model, no tokens.
#
# Channel knowledge comes from config/channels.conf, site login signals from config/probes.conf.
# Nothing about a specific job board is hardcoded here.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$ROOT/config/channels.conf"
PROBES="$ROOT/config/probes.conf"

CH="${1:-}"
LOGIN_PROBE=1
[ "${2:-}" = "--no-login-probe" ] && LOGIN_PROBE=0
[ -n "$CH" ] || { echo "usage: apply-preflight.sh <channel> [--no-login-probe]" >&2; exit 2; }

PORT="${BRAVE_CDP_PORT:-9222}"
TODAY="$(date +%F)"
REG="$ROOT/applied-jobs-registry.md"

trim() { local s="${1:-}"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }
blocked() { echo "PREFLIGHT BLOCKED ($CH): $1"; echo "[preflight] BLOCKED: $1" >&2; exit 3; }

# ---------------------------------------------------------------------------
# config: find this channel's row (exact match wins, then a glob row, then `*`)
# ---------------------------------------------------------------------------
CHLOG=""; CAP=30; SITES=""; LISTED=0
if [ -f "$CONF" ]; then
  ROW=""; FALLBACK=""
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    name="$(trim "$(printf '%s' "$line" | cut -d'|' -f1)")"
    if [ "$name" = "$CH" ]; then ROW="$line"; LISTED=1; break; fi
    case "$name" in
      *'*'*) case "$CH" in $name) [ -n "$ROW" ] || ROW="$line"; LISTED=1 ;; esac ;;
      '*')   FALLBACK="$line" ;;
    esac
  done < "$CONF"
  [ -n "$ROW" ] || ROW="$FALLBACK"
  if [ -n "$ROW" ]; then
    CHLOG="$(trim "$(printf '%s' "$ROW" | cut -d'|' -f4)")"
    c="$(trim "$(printf '%s' "$ROW" | cut -d'|' -f5)")"
    case "$c" in ''|*[!0-9]*) c=30 ;; esac
    CAP="$c"
    SITES="$(trim "$(printf '%s' "$ROW" | cut -d'|' -f6)")"
    [ "$CHLOG" = "-" ] && CHLOG=""
  fi
fi
[ -n "$CHLOG" ] || CHLOG="/dev/null"
[ "$SITES" = "-" ] && SITES=""

# ---------------------------------------------------------------------------
# 1. browser: reach Brave, then make sure agent-browser is attached to IT
# ---------------------------------------------------------------------------
# agent-browser SILENTLY launches its own bundled Chrome when it is not connected to a CDP
# endpoint. That browser has none of the operator's logins, so a run that forgets to attach sees
# "Sign In" everywhere and reports "signed out" — burning the whole run on a false diagnosis.
# Verify the attachment by CDP target-id overlap before believing any login state.
cdp_up() { curl -s --max-time 4 "http://127.0.0.1:${PORT}/json/version" >/dev/null 2>&1; }
if ! cdp_up; then
  blocked "Brave is not reachable on CDP ${PORT}. Start it with --remote-debugging-port=${PORT} (or let the launcher do it) and re-run."
fi

agent-browser connect "$PORT" >/dev/null 2>&1

attached_to_brave() {
  python3 - "$PORT" <<'PY'
import json, subprocess, sys, urllib.request
port = sys.argv[1]
try:
    cdp = json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/json/list", timeout=4))
except Exception:
    sys.exit(1)
ids = {t.get("id") for t in cdp if t.get("type") == "page"}
r = subprocess.run(["agent-browser", "tab", "list", "--json"], capture_output=True, text=True)
try:
    ab = {t["targetId"] for t in json.loads(r.stdout)["data"]["tabs"]}
except Exception:
    sys.exit(1)
sys.exit(0 if ids & ab else 1)
PY
}
if ! attached_to_brave; then
  blocked "agent-browser is NOT attached to the real browser on ${PORT} — it is driving its own bundled Chrome, which has no logins. This is a WRONG-BROWSER problem, not a logout. Re-attach (agent-browser connect ${PORT}) and re-run."
fi

# ---------------------------------------------------------------------------
# 2. login state, from config/probes.conf
# ---------------------------------------------------------------------------
# Two tiers, deliberately biased AGAINST a false "signed out":
#   tier 1: an already-open tab on the site that looks authenticated -> "in". Nothing is
#           navigated, so nothing of the operator's can be disturbed.
#   tier 2: open ONE new tab, switch agent-browser to it, probe, close it, restore the previous
#           tab. agent-browser acts on its ACTIVE tab, so switching is not optional.
# Only a POSITIVE logged-out signal blocks. Ambiguity is "unknown" and ignored.
tabs_json() { agent-browser tab list --json 2>/dev/null; }

tab_ids() {
  tabs_json | python3 -c 'import json,sys;print(" ".join(t["tabId"] for t in json.load(sys.stdin)["data"]["tabs"]))' 2>/dev/null
}
active_tab() {
  tabs_json | python3 -c 'import json,sys
ts=json.load(sys.stdin)["data"]["tabs"]
print(next((t["tabId"] for t in ts if t.get("active")),""))' 2>/dev/null
}

# an open tab whose URL proves a signed-in session (probes.conf `tab=` group)
auth_tab_for() { # host, tab_signals
  tabs_json | python3 -c '
import json,sys
host=sys.argv[1].lower()
sigs=[s for s in sys.argv[2].split(";") if s]
for t in json.load(sys.stdin)["data"]["tabs"]:
    u=(t.get("url") or "").lower()
    if host in u and any(s.lower() in u for s in sigs):
        print(t["tabId"]); break' "$1" "$2" 2>/dev/null
}

IN_SIG=""; OUT_SIG=""; TAB_SIG=""
probe_signals() { # site -> fills IN_SIG / OUT_SIG / TAB_SIG
  IN_SIG=""; OUT_SIG=""; TAB_SIG=""
  [ -f "$PROBES" ] || return 0
  local line f
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    [ "$(trim "$(printf '%s' "$line" | cut -d'|' -f1)")" = "$1" ] || continue
    f="$(trim "$(printf '%s' "$line" | cut -d'|' -f2)")"; IN_SIG="${f#in=}"
    f="$(trim "$(printf '%s' "$line" | cut -d'|' -f3)")"; OUT_SIG="${f#out=}"
    f="$(trim "$(printf '%s' "$line" | cut -d'|' -f4)")"; TAB_SIG="${f#tab=}"
    # a site with no configured signals cannot be judged
    return 0
  done < "$PROBES"
}

has_sig() { printf '%s' "$1" | grep -qiF -- "$2"; }

classify() { # body, url -> in|out|unknown
  local probe="$2
$1" sig
  if [ -n "$OUT_SIG" ]; then
    local IFS=';'
    for sig in $OUT_SIG; do [ -n "$sig" ] || continue; has_sig "$probe" "$sig" && { echo out; return; } ; done
  fi
  if [ -n "$IN_SIG" ]; then
    local IFS=';'
    for sig in $IN_SIG; do [ -n "$sig" ] || continue; has_sig "$probe" "$sig" && { echo in; return; } ; done
  fi
  echo unknown
}

probe_site() { # name url -> in|out|unknown
  local name="$1" url="$2" host prev before after tid out u verdict
  host="$(printf '%s' "$url" | sed -E 's#^https?://([^/]+).*#\1#' | sed 's/^www\.//')"

  probe_signals "$name"
  if [ -z "$IN_SIG$OUT_SIG" ]; then
    echo "unknown (no probe rules for '${name}' in config/probes.conf)"
    return
  fi

  prev="$(active_tab)"
  before="$(tab_ids)"
  agent-browser tab new >/dev/null 2>&1
  after="$(tab_ids)"
  tid="$(python3 -c '
import sys
b=set(sys.argv[1].split()); a=set(sys.argv[2].split())
n=sorted(a-b)
print(n[0] if n else "")
' "$before" "$after" 2>/dev/null)"
  [ -n "$tid" ] || { echo unknown; return; }

  agent-browser tab "$tid" >/dev/null 2>&1
  agent-browser open "$url" >/dev/null 2>&1
  agent-browser wait 3500 >/dev/null 2>&1
  out="$(agent-browser eval "JSON.stringify({u:location.href,t:(document.body?document.body.innerText:'').slice(0,1200)})" 2>/dev/null)"
  agent-browser tab close "$tid" >/dev/null 2>&1
  [ -n "$prev" ] && agent-browser tab "$prev" >/dev/null 2>&1

  u="$(printf '%s' "$out" | python3 -c 'import json,sys
try: print((json.loads(sys.stdin.read()) or {}).get("u",""))
except Exception: print("")' 2>/dev/null)"
  verdict="$(classify "$out" "$u")"

  # A live authenticated TAB outranks a "signed out" probe: the probe can land on a different
  # country host than the one the operator is actually signed in on.
  if [ "$verdict" = out ] && [ -n "$TAB_SIG" ]; then
    [ -n "$(auth_tab_for "$host" "$TAB_SIG")" ] && verdict=in
  fi
  echo "$verdict"
}

SESSION_LINES=""; SIGNED_OUT=""
if [ "$LOGIN_PROBE" = 1 ]; then
  for spec in $SITES; do
    name="${spec%%=*}"; url="${spec#*=}"
    st="$(probe_site "$name" "$url")"
    SESSION_LINES="${SESSION_LINES}- ${name}: ${st}"$'\n'
    case "$st" in out*) SIGNED_OUT="${SIGNED_OUT}${SIGNED_OUT:+, }${name}" ;; esac
  done
fi

# ---------------------------------------------------------------------------
# 3. budget (this channel's own log, today only)
# ---------------------------------------------------------------------------
APPLIED_TODAY=0
if [ -f "$CHLOG" ] && [ "$CHLOG" != "/dev/null" ]; then
  # grep -c prints 0 AND exits 1 when there are no matches — never add "|| echo 0" here.
  APPLIED_TODAY="$(grep -cE "^\| *${TODAY} *\|.*\| *applied *\|" "$CHLOG" 2>/dev/null)"
  APPLIED_TODAY="${APPLIED_TODAY:-0}"
fi
REMAINING=$(( CAP - APPLIED_TODAY ))
[ "$REMAINING" -lt 0 ] && REMAINING=0

RUNS_TODAY="$(ls -1 "$ROOT/logs/${CH}-${TODAY//-/}"*.log 2>/dev/null | wc -l | tr -d ' ')"

# ---------------------------------------------------------------------------
# 4. already-applied digest (dedupe key: company + similar title)
# ---------------------------------------------------------------------------
DIGEST="$(grep -E "^\| *20[0-9]{2}-" "$REG" 2>/dev/null \
  | awk -F'|' '{t=$3; c=$4; gsub(/^[ \t]+|[ \t]+$/,"",t); gsub(/^[ \t]+|[ \t]+$/,"",c); if(t!=""&&c!="") print t" @ "c}' \
  | awk '!seen[$0]++' | tail -150)"

# ---------------------------------------------------------------------------
# 5. report
# ---------------------------------------------------------------------------
echo "## PREFLIGHT (generated by tools/apply-preflight.sh — shell only, costs no tokens)"
echo
echo "- Now: ${TODAY} $(date +%H:%M) · channel: **${CH}**"
echo "- Brave CDP ${PORT}: up"
if [ "$LISTED" = 0 ]; then
  echo "- NOTE: '${CH}' is not listed in config/channels.conf — using the fallback row."
  echo "  Add it with \`tools/new-channel.sh\` or a line in channels.conf so its cap/log are right."
fi
if [ "$LOGIN_PROBE" = 1 ]; then
  printf '%s' "$SESSION_LINES"
else
  echo "- session probe: skipped"
fi
echo "- Submitted today on **this channel**: ${APPLIED_TODAY}/${CAP} → **remaining budget ${REMAINING}**"
echo "- Runs started today for this channel: ${RUNS_TODAY}"
echo "- Start the run with **${REMAINING}** submissions as the ceiling; do not exceed it."
echo
echo "### Already applied — do NOT apply to these again (any channel, dedupe key: company + similar title)"
echo
if [ -n "$DIGEST" ]; then
  printf '%s\n' "$DIGEST" | sed 's/^/- /'
else
  echo "- (registry empty)"
fi

if [ -n "$SIGNED_OUT" ]; then
  blocked "logged out of: ${SIGNED_OUT}. Nothing can be submitted until the operator signs back in."
fi

exit 0
