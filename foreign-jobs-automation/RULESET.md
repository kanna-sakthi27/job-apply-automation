## APPLICANT OVERRIDES 2026-09-07 (apply to every run)
1. HIT 30/DAY PER CHANNEL: daily target is 30 submitted applications per channel. Do NOT stop early while in-scope supply remains. Per-run attempt cap 15 (LinkedIn: 30). Keep rotating keywords/markets (US/UK/IE/EU-English/CA/SG/AU/remote) until 30/day is reached or the fresh pool is genuinely exhausted; then log a RUN SUMMARY with counts.
2. UNANSWERED QUESTION -> ASK, DON'T SKIP: if a required screening question has no answer in the bank, do NOT abandon/skip it silently. Send the candidate a Telegram message via conversations_send to the configured chat (user ${TELEGRAM_CHAT_ID}): job title @ company, the EXACT question text and options, note the application is paused on the candidate's answer, log it in the run-log section 5, then CONTINUE with other jobs. If the candidate answers before the run ends, come back and complete it.

# Foreign Direct-Apply Automation — Ruleset (v1, 2026-09-07)

Operating rules for scheduled runs that apply **directly on foreign tech companies' own career sites / ATS** plus Indeed, for the candidate. Built 2026-09-07 by extending the LinkedIn auto-apply system (`linkedin-automation/`). Every run reads THIS file first, then the playbook, registry, company list, and the shared answer bank.

> **Canonical files**
> - This ruleset: `foreign-jobs-automation/RULESET.md`
> - ATS mechanics: `ATS_PLAYBOOK.md` (same dir)
> - Company seed list: `COMPANY_TARGETS.md` (same dir)
> - Learned per-company registry (append-only): `ATS_REGISTRY.md` (same dir)
> - Answer bank (verbatim answers): `linkedin-automation/answers.md`
> - Foreign run log + day-cap source: `foreign-jobs-automation/run-log.md` §6 (foreign has its OWN 30/day budget, candidate policy 2026-09-07)
> - CV to upload everywhere: `linkedin-automation/cv/CV.pdf` (canonical; matches the candidate's latest upload — md5 1b2229c6…).

## 1. Mission

Apply to **Senior/Lead/Manager DevOps / Cloud / Platform / SRE / DevSecOps / Infrastructure (cloud) / Linux roles** — including **DevOps Manager, Cloud Manager, Infrastructure Manager, Linux Team Lead, SRE Manager, Platform Manager, DevOps Team Lead, Engineering Manager (cloud/infra/DevOps), Head of DevOps/Cloud** — at companies in **visa-sponsoring foreign countries — priority CANADA and SINGAPORE**, then Australia, UK, Ireland, Germany/Netherlands (EU), UAE, and truly remote-global employers. Use the company's own careers portal ("direct apply"), then Indeed Instant Apply for the same country, then LinkedIn Easy Apply only as a tie-breaker when the other two yield nothing fresh. Target: **30 submitted applications per day total** (shared budget with LinkedIn runs), reported to Telegram after every run.

## 2. Hard guardrails (never cross — same spirit as the LinkedIn ruleset)

1. **Never invent facts.** All answers come from `linkedin-automation/answers.md`. CLAIM (candidate policy 2026-09-07): AWS, Terraform, CloudFormation, Ansible, SaltStack, Puppet, Jenkins, Azure DevOps, **GitLab CI/CD**, Docker, Kubernetes, Grafana, ELK, Bash/Shell, YAML/JSON, MS SQL/PostgreSQL. NEVER claim: **ArgoCD/GitOps tooling** (willing to learn — only as free-text note, never a Yes tick), Python, Go, GCP/Azure architect certs, Java, Rust, Kotlin. Required non-claimable tool → skip + log.
2. **No money/visa guesswork.** Salary **apply-floor USD <FLOOR_MONTHLY_USD>/mo** (set in answers.md); EXPECTED salary to state in forms stays USD <EXPECTED_MONTHLY_USD>/mo. Floor conversions: ≈ the per-country floor equivalents in answers.md §2. With the answers.md §2 conversion table for expected. Nationality: **<YOUR NATIONALITY>**; residence and right-to-work status per answers.md §0 → sponsorship requirement per answers.md. Answer visa/sponsorship questions **truthfully and SUBMIT** — let the employer decide. **Skip only when the posting explicitly excludes**: "must be eligible to work in Canada" is NOT an exclusion (standard boilerplate); but "Canadian citizens/PR only", "no sponsorship / no LMIA", "must have existing work permit/right to work", "not open to overseas applicants", "SC clearance / 5-yr UK residency", "EU passport required", "Singaporeans/PR only" ARE exclusions → skip + log.
3. **Scope filter (DevOps/cloud ONLY).** Same list as LinkedIn RULESET §2.3a. Never pure software-dev, data/ML/AI, QA, security (non-DevSecOps), pure networking, DBA, or "customer/support engineer" roles.
4. **Seniority filter (EXPANDED by candidate policy 2026-09-07).** In-scope titles: Senior/Lead/Staff/Principal/**Manager/Team Lead/Head** + DevOps/SRE/Platform/Infrastructure/Reliability/Cloud/Linux — INCLUDING **DevOps Manager, Cloud Manager, Infrastructure Manager, Linux Team Lead, SRE Manager, Platform Manager, DevOps Team Lead, Engineering Manager (cloud/infra/DevOps), Head of DevOps/Cloud/Infrastructure**. Technical management over DevOps/cloud/infra is IN; non-technical management out. No junior/mid-only titles, no internships. Contracts only if clearly senior/manager-scope AND salary ≥ floor.
5. **Daily budget: 30 applications/day on foreign-direct surfaces (candidate policy 2026-09-07; LinkedIn and Indeed keep their own separate 30/day budgets).** Before EACH submission, count applied rows dated today (Asia/Kuala_Lumpur) in foreign-jobs-automation/run-log.md §6 (foreign's OWN log); STOP once 30. Per-run soft target **10 applications** (may stop earlier if the country's fresh in-scope pool is exhausted; never force low-quality submissions).
6. **Never submit with a required question unanswered** per bank → skip + log under "Unanswered questions" (answers.md §5) with exact wording.
7. **Anti-spin:** max ~6 minutes or 3 fresh snapshots per job without forward progress → SKIP + log (reason) and move on. Never click the same element twice. If a known ATS wall appears (see playbook §Walls) → skip after at most 2 attempts, do NOT retry-loop.
8. **Captcha / checkpoint / "verify you are human" / SMS OTP walls** → STOP that application immediately, log it, move on. Never fight captchas. If a full-site bot-wall appears (Cloudflare etc.) → abandon that company this run.
9. **Signups:** prefer **"Continue with Google" / "Sign in with Google"** (candidate policy is logged into Google in Brave). If the ATS REQUIRES a new account and offers no Google/LinkedIn SSO and no "apply as guest" → **skip + log** ("needs account: <ATS>, no Google SSO") — never create accounts with invented passwords, never use the candidate's email with a password we don't own.
10. **Never touch other people's/live tabs.** Work ONLY in tabs this run opened (label `fj-<country>-<company>`), never navigate/act on the candidate's existing LinkedIn/Outlook/Gemini/Indeed tabs (a human may be mid-flow — e.g. an Indeed screener was open 2026-09-07). Close your own tabs when done with a company. Never close hers.
11. **If Brave is not attached** (`browser action=status profile=brave` → cdpReady false) → relaunch via `su - "$USER" -c 'export DISPLAY=:0; nohup brave-browser --remote-debugging-port=9222 --restore-last-session >/tmp/brave-debug.log 2>&1 &'`, wait, re-check once. Still down → stop, report "browser unavailable".
12. **Rate limits / 429s** → stop after 2 hits, report partial, quit cleanly.
13. The **answer bank always wins** over this file. Report format ≤ ~180 words (unless a blocker needs detail).
14. **Hard blockers → SKIP and CONTINUE (candidate policy 2026-09-07):** never abandon a run or leave a needs-review draft on one job. Unanswerable required question / ATS wall / form bug → skip + log that job and keep applying until the run target or shared day cap (30) is reached.

## 3. Country rotation & visa reality (per scheduled job)

| Job | Countries | Visa notes for the candidate (the authorised countries dual, needs sponsorship) |
|---|---|---|
| Canada 10:00 & 22:00 MYT | **Canada** | LMIA / Global Talent Stream. Boilerplate "must be eligible to work in Canada" is fine to proceed; hard-exclude only explicit citizen/PR-only or no-sponsorship language. |
| Singapore 15:00 & 21:00 MYT | **Singapore** | Employment Pass (COMPASS). Proceed unless "Singaporeans/PR only" or "open to citizens/PR". |
| Rotation 20:00 & 23:00 MYT | Rotate: **UK → Finland → Ireland → Netherlands → Germany → other EU → remote-global** (candidate policy 2026-09-07: add Finland + any Europe, but English-only) | **ENGLISH-ONLY RULE (candidate policy 2026-09-07):** apply ONLY where the posting is in English AND the working language is English — skip any role requiring Finnish/German/French/Swedish/Dutch/etc. (even 'nice-to-have bilingual' = wall unless English clearly suffices). UK: skip SC-clearance/5-yr-residency/settled-status. Finland: skip roles requiring Finnish; many Helsinki tech roles are English-OK (Smartly, Wolt, Supercell infra, Unity, KONE digital…). IE: CSEP ok. DE/NL/EU: skip non-English postings; Blue Card employers ok. UAE: on-site ok ≥ the UAE floor in answers.md. Remote-global: Canonical/GitLab/Elastic-type, sponsorship Yes. |

Company selection (registry-gated — candidate policy 2026-09-08): only attempt a company's OWN careers site when its last ATS_REGISTRY.md row is `applied-OK`, `needs-review` (roles existed) or `wall-tool`. Companies logged `no-roles` / `wall-404` / `wall-dns` / `wall-redirect` / `wall-ui` in the last 7 days are SKIPPED — never re-open their boards this run. Prefer companies whose fresh opening was surfaced by the Indeed/LinkedIn passes. Max 3 direct-ATS companies per run, ≤3 min each.

## 4. Channel priority per run (ACCURACY-FIRST — candidate policy 2026-09-08)

Measured yields 09-07/08: LinkedIn ~6/day, Indeed ~2-3/day, Glassdoor ~3/day, direct company-ATS ~0/day (46 no-roles + 26 needs-review + 14 board walls). To actually land foreign applications, run in THIS order:

1. **Indeed country site FIRST** (`ca/sg/au/uk/ie/de/nl/ae.indeed.com`): `q=devops OR cloud OR platform OR sre OR "infrastructure manager"`, sort=date, fromage=3, country-wide location. Apply via **Instant Apply (smartapply)** where offered. For "Apply on company site" postings, follow to the employer ATS ONLY if the ATS family is **Greenhouse / Lever / Ashby** (guest/Google apply) or **Workday with Google SSO** — otherwise skip + log (Taleo/SuccessFactors/iCIMS/OTP walls). Open your OWN tab; never touch the candidate's Indeed tabs.
2. **LinkedIn Easy Apply SECOND** (new labeled tab, never the candidate's LinkedIn tab): `linkedin.com/jobs/search/?f_AL=true&f_TPR=r86400&keywords=<DevOps Manager / Cloud Manager / Infrastructure Manager / Linux Team Lead / Senior DevOps Engineer>&location=<Country>&sortBy=DD`. Apply to every in-scope senior/manager role passing guardrails (per LinkedIn skill gotchas: modal div, clickCoords, save-draft interstitial).
3. **Direct company ATS THIRD, registry-gated only** (≤3 companies, ≤3 min each — §3): visit a company's careers site only when its last ATS_REGISTRY row proves roles exist there.

## 5. Runtime flow (in order)

1. Read this ruleset + ATS_PLAYBOOK.md + COMPANY_TARGETS.md + ATS_REGISTRY.md + `linkedin-automation/answers.md`.
2. Count today's `applied` rows (Asia/Kuala_Lumpur date) in `foreign-jobs-automation/run-log.md` §6 → remaining = 30 − count (foreign's own budget). **If ≤ 0 → report and stop.**
3. Verify Brave attach (profile `brave`). Then confirm Google session once per run: open a labeled tab to `https://accounts.google.com` — if it shows a signed-in account (the candidate's), note "Google OK" and close the tab. If signed-out → Google SSO path unavailable: rely on guest-apply/email paths; do NOT attempt Google login (the candidate's manual step) — log it.
4. **Indeed pass** (new labeled tab): country search per §4.1 — Instant Apply → smartapply wizard (mechanics per ATS_PLAYBOOK §Indeed); "Apply on company site" → follow only for Greenhouse/Lever/Ashby/Workday-Google-SSO. Log each outcome; re-check the foreign 30/day budget (run-log.md §6) and the common registry **before every submit**.
5. **LinkedIn Easy Apply pass** (new labeled tab): country-filtered search per §4.2; apply to every in-scope role passing guardrails; log each.
6. **Direct-ATS pass (registry-gated, ≤3 companies, ≤3 min each)** per §4.3: careers page must show a usable job list within 2 snapshots — else log `needs-review`, close the tab, move on. After each company append/update ATS_REGISTRY.md.
7. Log every outcome to `run-log.md` §6 (foreign's own log) as rows: `date | title @ company, country | applied/skipped/needs-review | short reason`, plus a RUN SUMMARY row. Also append successful submits to the COMMON registry `applied-jobs-registry.md`.
8. **Final message = the Telegram report** (delivery announce posts it): country, applied list (title @ company — country), skipped count + top reasons, walls/unanswered Qs, day total X/30. ≤180 words.

## 6. Idempotency & dedupe

- **Cross-apply guard (candidate policy 2026-09-07): BEFORE applying to any job, check the COMMON registry
  `applied-jobs-registry.md`** (shared across LinkedIn/Indeed/Glassdoor/
  foreign-direct/Jaabz). Same company + same/similar title already applied on ANY channel → SKIP + log.
  Append to the registry after every successful submit.
- Before applying to any job, grep `run-log.md` §6 + the common registry for the company+title (any date). Applied before → skip silently.
- ATS_REGISTRY.md rows with `applied-OK` or `no-roles` in the last 7 days → don't re-enter that company's job board this run (but new postings at applied companies are fine to check next week).
- A submission is "applied" ONLY when a confirmation was seen ("Application submitted / Thank you / We've received your application"). Mid-form abandonment → log `needs-review` with exact stop point (never blind-resubmit).

## 7. Failure modes (same table spirit as LinkedIn ruleset)

| Symptom | Action |
|---|---|
| Brave attach fails | Relaunch once (guardrail 11); else report "browser unavailable" |
| accounts.google.com signed-out | Log "Google SSO unavailable"; use guest paths; no login attempt |
| Captcha / Cloudflare / OTP wall | Skip that application/company, log, continue |
| ATS requires account w/o Google SSO | Skip + log (guardrail 9) |
| Required Q not in bank | Skip + log to §5, continue |
| 429 / rate limit | Stop after 2, report partial |
| ATS form stuck (Workable location bug etc.) | 2 attempts max → skip + log, per playbook §Walls |

## 8. Token discipline

Cheap model runs this (DeepSeek V4 Flash default). Use snapshot `query`/text reads over full snapshots, jq is N/A (browser) but keep page reads scoped. If a step explodes tokens, stop and report. One company at a time; slow = safe.
