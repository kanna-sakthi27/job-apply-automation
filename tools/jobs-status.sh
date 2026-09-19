#!/usr/bin/env bash
# jobs-status.sh — where the channels live, when they run, and what happened last time.
#
#   jobs-status.sh                    table of every channel in config/channels.conf
#   jobs-status.sh --channel <name>   detail for one channel
#
# Reads config/channels.conf, so it always agrees with the launcher and the pre-flight.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$ROOT/config/channels.conf"
cd "$ROOT" || exit 1
[ -f "$ROOT/.env" ] && set -a && . "$ROOT/.env" && set +a

ONLY=""
[ "${1:-}" = "--channel" ] && ONLY="${2:-}"
[ -f "$CONF" ] || { echo "missing $CONF" >&2; exit 2; }

echo "job-apply-automation — channel status"
echo "  as of     $(date '+%F %H:%M:%S %Z')"
echo "  runner    Command Code CLI  →  cmd -p <prompt> --yolo"
echo "  models    ${APPLY_MODELS:-<unset in .env>}"
echo "            (free models first; a paid fallback only while the quota gate allows)"
echo "  browser   agent-browser → CDP 127.0.0.1:${BRAVE_CDP_PORT:-9222}"
echo "  reports   Telegram chat ${TELEGRAM_CHAT_ID:-<unset in .env>}"
echo "  config    $CONF"
echo

python3 - "$ROOT" "$CONF" "$ONLY" <<'PY'
import glob, os, re, sys
from datetime import datetime, timedelta

root, conf, only = sys.argv[1:4]

def rows():
    out = []
    for line in open(conf, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        f = [x.strip() for x in line.split("|")]
        while len(f) < 6:
            f.append("")
        out.append(dict(zip(("name", "enabled", "schedule", "log", "cap", "sites"), f)))
    return out

def field_match(field, value):
    if field == "*":
        return True
    for part in field.split(","):
        if part.isdigit() and int(part) == value:
            return True
        if part.startswith("*/") and part[2:].isdigit() and value % int(part[2:]) == 0:
            return True
    return False

def next_run(sched, now):
    parts = sched.split()
    if len(parts) != 5:
        return None
    minute, hour, dom, month, dow = parts
    t = now.replace(second=0, microsecond=0) + timedelta(minutes=1)
    for _ in range(60 * 24 * 8):
        if (field_match(minute, t.minute) and field_match(hour, t.hour)
                and field_match(dom, t.day) and field_match(month, t.month)
                and field_match(dow, (t.weekday() + 1) % 7)):
            return t
        t += timedelta(minutes=1)
    return None

def human(delta):
    s = int(delta.total_seconds())
    if s < 3600: return f"in {s // 60}m"
    if s < 86400: return f"in {s // 3600}h{(s % 3600) // 60:02d}m"
    return f"in {s // 86400}d{(s % 86400) // 3600}h"

def applied_today(logpath):
    today = datetime.now().strftime("%Y-%m-%d")
    p = os.path.join(root, logpath)
    if not os.path.isfile(p):
        return 0
    n = 0
    for line in open(p, errors="ignore"):
        if re.match(rf"^\|\s*{today}\s*\|.*\|\s*applied\s*\|", line):
            n += 1
    return n

now = datetime.now()
data = [r for r in rows() if r["name"] != "*" and (not only or r["name"] == only)]
if only and not data:
    print(f"  no channel named '{only}' in channels.conf")
    sys.exit(0)

print(f"  {'CHANNEL':<19}{'ON':<4}{'SCHEDULE':<26}{'NEXT':<12}{'TODAY':<9}{'LAST RUN':<14}RESULT")
print(f"  {'-' * 18} {'-' * 3} {'-' * 25} {'-' * 11} {'-' * 8} {'-' * 13} {'-' * 20}")
for r in data:
    sched = r["schedule"]
    nxt = human(next_run(sched, now) - now) if sched not in ("", "-") else "manual"
    logs = sorted(glob.glob(os.path.join(root, "logs", f"{r['name']}-*.log")), key=os.path.getmtime)
    when, result, tail = "never", "—", "no run yet"
    if logs:
        last = logs[-1]
        when = datetime.fromtimestamp(os.path.getmtime(last)).strftime("%m-%d %H:%M")
        for ln in reversed(open(last, errors="ignore").read().splitlines()):
            if ln.strip():
                tail = ln.strip()[:44]
                break
        result = "failed" if "FAILED" in tail or "failed" in tail.lower() else "ok"
    print(f"  {r['name']:<19}{r['enabled']:<4}{sched:<26}{nxt:<12}{str(applied_today(r['log'])) + '/' + r['cap']:<9}{when:<14}{result}")
    if only:
        print(f"    cap      {r['cap']}/day · log {r['log']}")
        print(f"    sites    {r['sites']}")
        print(f"    last     {tail}")

print()
print("  run one by hand : tools/cron-run.sh <channel> [--dry-run]")
print("  install/refresh : tools/install-cron.sh [--dry-run]")
print("  add a channel   : tools/new-channel.sh <name> --site <label>=<url>")
PY
