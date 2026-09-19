#!/usr/bin/env bash
# new-channel.sh — scaffold a new job-apply channel from templates/.
#
#   new-channel.sh <name> [--site <label>=<url>] [--domain <domain>]
#                         [--schedule "<cron>"] [--cap <n>] [--no-skill]
#
#   --site      url to login-probe before each run (label must exist in config/probes.conf,
#               or the probe reports "unknown" and the run proceeds)
#   --domain    domain its tab lives on            (default: host of --site)
#   --schedule  crontab spec; omit for a manual-only channel
#   --cap       daily submission cap               (default 30)
#
# Creates:
#   prompts/<name>.md                        the runbook the agent executes
#   <name>-automation/RULESET.md             site deep-dive, to fill in as you learn
#   <name>-automation/answers.example.md     log template
#   <name>-automation/answers.md             this channel's live log (gitignored)
#   .commandcode/skills/<name>-job-apply/    skill, so the agent loads this channel on demand
# and appends a row to config/channels.conf.
#
# Nothing here is site-specific in code: the launcher runs whatever prompts/<name>.md exists,
# and the pre-flight reads the row you just added.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/templates"

NAME=""; SITE_LABEL=""; SITE_URL=""; DOMAIN=""; SCHEDULE="-"; CAP=30; MAKE_SKILL=1
while [ $# -gt 0 ]; do
  case "$1" in
    --site)     SITE_LABEL="${2%%=*}"; SITE_URL="${2#*=}"; shift 2 ;;
    --domain)   DOMAIN="$2"; shift 2 ;;
    --schedule) SCHEDULE="$2"; shift 2 ;;
    --cap)      CAP="$2"; shift 2 ;;
    --no-skill) MAKE_SKILL=0; shift ;;
    -h|--help)  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)         echo "unknown option: $1" >&2; exit 2 ;;
    *)          NAME="$1"; shift ;;
  esac
done

[ -n "$NAME" ] || { echo "usage: new-channel.sh <name> [--site label=url] [--schedule \"<cron>\"] [--cap N]" >&2; exit 2; }
case "$NAME" in
  *[!a-z0-9-]*|'') echo "channel name must be lowercase letters, digits and dashes: '$NAME'" >&2; exit 2 ;;
esac
case "$NAME" in
  linkedin|indeed|glassdoor|jaabz|selftest|*/*)
    echo "refusing to overwrite the built-in channel '$NAME'" >&2; exit 2 ;;
esac

DIR="$ROOT/${NAME}-automation"
PROMPT="$ROOT/prompts/$NAME.md"
[ -e "$PROMPT" ] && { echo "prompts/$NAME.md already exists — refusing to overwrite" >&2; exit 2; }
[ -e "$DIR" ]    && { echo "${NAME}-automation/ already exists — refusing to overwrite" >&2; exit 2; }

if [ -z "$DOMAIN" ] && [ -n "$SITE_URL" ]; then
  DOMAIN="$(printf '%s' "$SITE_URL" | sed -E 's#^https?://([^/]+).*#\1#')"
fi

SITES_FIELD="-"
if [ -n "$SITE_LABEL" ] && [ -n "$SITE_URL" ]; then
  SITES_FIELD="${SITE_LABEL}=${SITE_URL}"
fi

mkdir -p "$DIR" "$ROOT/prompts" "$ROOT/.commandcode/skills/$NAME-job-apply" "$ROOT/logs"

# Substitute the {{PLACEHOLDERS}}. Done in python so URLs cannot break a sed expression.
subst() { # <template> <destination>
  python3 - "$1" "$2" "$NAME" "${SITE_LABEL:-the site}" "${SITE_URL:-}" "$DOMAIN" <<'PY'
import pathlib, sys
tpl, dst, name, site, url, domain = sys.argv[1:7]
text = pathlib.Path(tpl).read_text(encoding="utf-8")
for key, val in {
    "CHANNEL": name,
    "SITE": site,
    "DOMAIN": domain or "<the-site-domain>",
    "SEARCH_URL": url or "<https://the-site/search>",
    "ROLE_SCOPE": "the role scope in your bank",
    "APPLY_MODE": "<the site's own apply flow>",
    "APPLY_MODE_LOWER": "<apply mode>",
    "CONFIRMATION_TEXT": "<the confirmation text this site shows>",
}.items():
    text = text.replace("{{%s}}" % key, val)
pathlib.Path(dst).write_text(text, encoding="utf-8")
PY
}

subst "$TPL/channel.prompt.md"  "$PROMPT"
subst "$TPL/channel.RULESET.md" "$DIR/RULESET.md"
subst "$TPL/channel.answers.md" "$DIR/answers.example.md"
cp "$DIR/answers.example.md" "$DIR/answers.md"
[ "$MAKE_SKILL" = 1 ] && subst "$TPL/channel.SKILL.md" "$ROOT/.commandcode/skills/$NAME-job-apply/SKILL.md"

# register it
ROW="${NAME}|yes|${SCHEDULE}|${NAME}-automation/answers.md|${CAP}|${SITES_FIELD}"
python3 - "$ROOT/config/channels.conf" "$ROW" <<'PY'
import pathlib, sys
conf, row = pathlib.Path(sys.argv[1]), sys.argv[2]
name = row.split("|", 1)[0]
lines = conf.read_text(encoding="utf-8").splitlines()
# insert before the fallback row, so `*` stays last
out, placed = [], False
for ln in lines:
    if not placed and ln.startswith("*|"):
        out.append(row); placed = True
    out.append(ln)
if not placed:
    out.append(row)
conf.write_text("\n".join(out) + "\n", encoding="utf-8")
PY

if [ -n "$SITE_LABEL" ] && ! grep -q "^${SITE_LABEL}|" "$ROOT/config/probes.conf" 2>/dev/null; then
  echo "NOTE: '${SITE_LABEL}' has no login-probe rules yet — add a line to config/probes.conf:"
  echo "      ${SITE_LABEL}|in=<logged-in marker text>|out=Sign in;/login|tab=<authenticated path>"
fi

echo "created channel '${NAME}':"
echo "  prompts/$NAME.md                          <- fill this in first"
echo "  ${NAME}-automation/RULESET.md             <- fill in as you learn the site"
echo "  ${NAME}-automation/answers.md             <- its run log (gitignored)"
if [ "$MAKE_SKILL" = 1 ]; then echo "  .commandcode/skills/$NAME-job-apply/SKILL.md"; fi
echo "  config/channels.conf                      <- row added"
echo
echo "next:"
echo "  1. edit prompts/$NAME.md — the apply path and the site's gotchas"
echo "  2. if --site was given, check the probe rules in config/probes.conf"
echo "  3. dry run (no model, no tokens):  tools/cron-run.sh $NAME --dry-run"
echo "  4. live run:                       tools/cron-run.sh $NAME"
if [ "$SCHEDULE" != "-" ]; then
  echo "  5. schedule it:                    tools/install-cron.sh"
else
  echo "  5. to schedule it, set --schedule \"<cron>\" in config/channels.conf"
  echo "     then re-run tools/install-cron.sh"
fi
