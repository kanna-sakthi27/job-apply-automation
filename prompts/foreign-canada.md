# foreign-canada — auto-apply run (Command Code)

You run headlessly under the Command Code CLI (`cmd -p`), started by
`tools/cron-run.sh` with the working directory set to the workspace root.
There is no human at the keyboard: never wait for input, never ask a question
in the terminal — use Telegram (below).

WORKSPACE ROOT — the launcher cds into the repository root before starting, so
every path below is relative to that root.

AUTHORITY
- `linkedin-automation/answers.md` §0 is the MASTER answer bank for every
  channel. Where any other text (including this prompt) disagrees with §0, §0 wins.
- Cross-channel dedupe source of truth: `applied-jobs-registry.md`.
  Check it before every submit; append a row after every confirmed submit.

BROWSER — the candidate's real logged-in Brave, driven by the agent-browser CLI.
(There is no OpenClaw `browser` tool any more; do not look for one.)
    agent-browser connect 9222        # attach to the running Brave (once per run)
    agent-browser snapshot -i         # accessibility tree with @eN element refs
    agent-browser click @e3
    agent-browser fill @e4 "text"
    agent-browser press Enter
    agent-browser eval "<javascript>" # e.g. agent-browser eval "location.reload()"
    agent-browser wait 2000           # milliseconds
  Re-snapshot after every page change. Full guide: `agent-browser skills get core`.
  Use the existing session; NEVER log in. Logged out -> report "needs login" and move on.
  TABS — tidy up after every job: close the tab(s) YOU opened once that job is done
  (submitted, skipped, or blocked on a missing answer). `agent-browser tab list` shows the
  tabs and `agent-browser tab close <n>` closes one. NEVER close a tab you did not open
  (the candidate's own tabs stay untouched), and never run `close --all`. If you are closing out a
  job because you had no answer for it, note it in the channel log AND send the Telegram
  message before moving on.

  TOKEN DISCIPLINE — read the ruleset + answer bank ONCE at the start, then work from what
  you read; do not re-read the same files. Prefer compact DOM probes (`agent-browser eval`)
  over full snapshots, and never re-open a page or re-snapshot the same state more than
  twice. On a wall, skip fast rather than retrying.

TELEGRAM — the only way to reach the candidate (chat ${TELEGRAM_CHAT_ID}):
    echo "your message" | tools/tg-notify.sh
  Use it for a missing required answer, and for the end-of-run summary.

CONCURRENCY: the launcher already holds an exclusive browser lock, so this run is
the only one using Brave. Do not check for, or wait on, other jobs.

---
Foreign direct-apply run — CANADA. Follow foreign-jobs-automation/RULESET.md exactly (read it + ATS_PLAYBOOK.md + COMPANY_TARGETS.md + ATS_REGISTRY.md + foreign-jobs-automation/run-log.md + linkedin-automation/answers.md (shared answer bank) first). Drive the candidate's real Brave with the agent-browser CLI (see the header; `agent-browser connect 9222`).

CONCURRENCY: the launcher already holds an exclusive browser lock; you are the only run using Brave. Do not poll or wait for other jobs. 

CHANNEL ORDER (candidate policy 2026-09-08 accuracy retune - direct-ATS crawling yielded ~0; run THIS order): 1) Indeed country site FIRST (country.indeed.com, q='devops OR cloud OR platform OR sre OR infrastructure manager', sort=date, fromage=3): Instant Apply via smartapply wizard; for 'Apply on company site' postings follow ONLY to Greenhouse/Lever/Ashby or Workday-with-Google-SSO, else skip+log. 2) LinkedIn Easy Apply SECOND for the country (f_AL=true, f_TPR=r86400, manager+senior keywords). 3) Direct company ATS THIRD, registry-gated, MAX 3 companies x 3 min each: only if ATS_REGISTRY.md shows that company had roles (applied-OK/needs-review/wall-tool); skip companies logged no-roles/wall-404/wall-dns/wall-redirect/wall-ui in last 7 days. Do NOT re-open dead boards. indeed.com, then LinkedIn Easy Apply tie-breaker only if budget allows. Submit via company ATS using Google sign-in where offered; skip+log any account-only/OTP/captcha/right-to-work-exclusion wall (never invent answers, never create passwords). DAILY BUDGET (Foreign direct, candidate policy 2026-09-07): 30 applications max/day on company career sites/ATS, counted from foreign-jobs-automation/run-log.md section 6 (rows dated today MYT with '| applied |'). LinkedIn and Indeed each keep their own separate 30/day budgets - do NOT count those here. Upload canonical CV linkedin-automation/cv/CV.pdf. Log every outcome to foreign-jobs-automation/run-log.md section 6 (applied/skipped/needs-review rows + a RUN SUMMARY row) + ATS_REGISTRY.md. Final summary must be the Telegram report (≤180 words: applied list, skipped+reasons, walls, day total X/30).

SCOPE-TITLES (candidate policy 2026-09-07 EXPANSION): also target TECHNICAL-MANAGER roles — DevOps Manager, Cloud Manager, Infrastructure Manager, Linux Team Lead, SRE Manager, Platform Manager, DevOps Team Lead, Engineering Manager (cloud/infra/DevOps teams), Head of DevOps/Cloud/Infrastructure. Engineer titles stay as before (Senior/Lead/Staff/Principal DevOps/Cloud/Platform/SRE/Infra). Non-technical management out of scope.

SALARY-FLOOR (candidate policy 2026-09-07): apply-floor is USD <FLOOR_MONTHLY_USD>/mo - SKIP postings whose band is below the per-country floor equivalents in answers.md, SAR 26,250/mo. EXPECTED salary to state in forms stays USD <EXPECTED_MONTHLY_USD>/mo.

## APPLICANT OVERRIDES 2026-09-07 (apply to every run)
1. HIT 30/DAY PER CHANNEL: daily target is 30 submitted applications per channel. Do NOT stop early while in-scope supply remains. Per-run attempt cap 15 (Foreign-CA: attempt up to day cap). Keep rotating keywords/markets (US/UK/IE/EU-English/CA/SG/AU/remote) until 30/day is reached or the fresh pool is genuinely exhausted; then log a RUN SUMMARY with counts.
2. UNANSWERED QUESTION -> ASK, DON'T SKIP: if a required screening question has no answer in the bank, do NOT abandon/skip it silently. Send the candidate a Telegram message via tools/tg-notify.sh: job title @ company, the EXACT question text and options, note the application is paused on the candidate's answer, log it in the run-log section 5, then CONTINUE with other jobs. If the candidate answers before the run ends, come back and complete it.
DEDUPE (candidate policy 2026-09-08): BEFORE every submit grep the COMMON registry applied-jobs-registry.md for company + title keyword (all channels share it) AND foreign-jobs-automation/run-log.md section 6 - if applied before on ANY channel, skip+log. After every confirmed submit, append a row to applied-jobs-registry.md (channel 'foreign').
