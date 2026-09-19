#!/usr/bin/env bash
# run-stats.sh — token + cost accounting for auto-apply runs, read from the Command Code
# session transcripts. This is how we prove a change actually reduced token usage.
#
#   run-stats.sh --window <start_epoch> <end_epoch>   tokens/cost for the run in that window
#   run-stats.sh --recent [N]                         last N runs (default 12), by start time
#   run-stats.sh --since <epoch>                      everything since an epoch
#
# A run = one session transcript (a model switch resumes the same session, so attempts do not
# fragment the accounting). Sessions are attributed by file mtime falling inside the window.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# the CLI names a project dir by lowercasing the cwd and turning every non-alphanumeric into '-'
# /home/you/Documents/Job_Automation -> home-you-documents-job-automation
SLUG="$(printf '%s' "$ROOT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/^-\+//; s/-\+$//')"
PROJ="$HOME/.commandcode/projects/$SLUG"

[ -d "$PROJ" ] || { echo "no session dir at $PROJ" >&2; exit 1; }

MODE="${1:---recent}"
case "$MODE" in
  --window) S="${2:?start epoch}"; E="${3:?end epoch}" ;;
  --since)  S="${2:?epoch}";       E="$(date +%s)" ;;
  --recent) S=0;                   E="$(date +%s)" ;;
  *) echo "usage: run-stats.sh [--window <s> <e> | --since <s> | --recent [N]]" >&2; exit 2 ;;
esac
N="${3:-12}"
[ "$MODE" = "--recent" ] && N="${2:-12}"

python3 - "$PROJ" "$S" "$E" "$MODE" "$N" <<'PY'
import glob, json, os, sys, time
from datetime import datetime

proj, s, e, mode, n = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4], int(sys.argv[5])

def usage_of(path):
    tot = {"in": 0, "out": 0, "cacheRead": 0, "cacheWrite": 0, "cost": 0.0}
    turns = 0
    for line in open(path, errors="ignore"):
        try:
            o = json.loads(line)
        except Exception:
            continue
        turns += 1
        u = o.get("usage") or (o.get("message") or {}).get("usage") or {}
        if u.get("inputTokens") is not None: tot["in"] += u["inputTokens"] or 0
        if u.get("outputTokens") is not None: tot["out"] += u["outputTokens"] or 0
        if u.get("cacheReadTokens") is not None: tot["cacheRead"] += u["cacheReadTokens"] or 0
        if u.get("cacheWriteTokens") is not None: tot["cacheWrite"] += u["cacheWriteTokens"] or 0
        if u.get("costUsd") is not None: tot["cost"] += u["costUsd"] or 0
    return tot, turns

rows = []
for f in glob.glob(os.path.join(proj, "*.jsonl")):
    if f.endswith("checkpoints.jsonl"):
        continue
    mt = os.path.getmtime(f)
    if not (s <= mt <= e):
        continue
    tot, turns = usage_of(f)
    if turns == 0:
        continue
    rows.append((mt, f, turns, tot))

rows.sort()
if mode == "--recent":
    rows = rows[-n:]

if not rows:
    print("no sessions in window")
    sys.exit(0)

gi = go = gr = gc = 0
gcost = 0.0
print(f"{'started':<17}{'turns':>6}{'input':>12}{'cacheRead':>12}{'output':>9}{'cost$':>9}  session")
for mt, f, turns, t in rows:
    print(f"{datetime.fromtimestamp(mt):%m-%d %H:%M:%S} {turns:>6}{t['in']:>12,}{t['cacheRead']:>12,}{t['out']:>9,}{t['cost']:>9.4f}  {os.path.basename(f)[:8]}")
    gi += t["in"]; go += t["out"]; gr += t["cacheRead"]; gc += t["cacheWrite"]; gcost += t["cost"]

print(f"{'TOTAL':<17}{'':>6}{gi:>12,}{gr:>12,}{go:>9,}{gcost:>9.4f}  {len(rows)} run(s)")
print(f"\ncache read = {gr:,}  cache write = {gc:,}  (a run's static prompt is re-read every turn,")
print("so shrinking the prompt/ bank is the single biggest lever on the input column.)")
PY
