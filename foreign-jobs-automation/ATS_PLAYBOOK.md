# ATS Playbook — mechanics for direct applications (v1, 2026-09-07)

Read before every run. Companion to RULESET.md. Goal: recognize the ATS family from the URL, know the fastest honest apply path, and skip known walls quickly (anti-spin).

## 0. Universal per-job sequence

1. Read the posting. Check guardrails: senior/lead DevOps/cloud scope (§3 scope), country exclusion language (RULESET §2.2), salary if posted (≥ floor), required skills (must be in answer bank/CV).
2. Dedupe: grep answers.md §6 + ATS_REGISTRY.md for company+title.
3. Find **Apply** → if it opens the company's own ATS in a NEW tab (not the current tab), that new tab is ours to drive; if it opens a tab/session we did not create, do not touch — open the ATS URL fresh instead.
4. Fill only from `linkedin-automation/answers.md`. Reuse profile facts: email `you@example.com`, phone `+10000000000` (Malaysia; when a country code picker is present use `00000000000`), location city `<YOUR CITY>` / country `<YOUR COUNTRY>`, notice 30 days, salary per §2 table of answers.md, sponsorship Yes (outside the authorised countries), nationality <YOUR NATIONALITY>.
5. Upload CV: `linkedin-automation/cv/CV.pdf`.
6. Submit only after every required field is answered from the bank. Verify confirmation text.
7. Log to answers.md §6 + ATS_REGISTRY.md.

## 1. ATS family detection (URL patterns)

| Family | URL contains | Apply posture |
|---|---|---|
| Greenhouse | `boards.greenhouse.io` / `grnh.se` | **Guest apply OK** — fastest. "Apply for this job" → email form → upload CV → submit. Some use "Apply with LinkedIn"/"Apply with Indeed" — skip those buttons, use plain email form. |
| Lever | `jobs.lever.co` | "Apply for this role" → **"Continue with Google"** if present (candidate policy logged in) else LinkedIn → else email form (creates Lever candidate record, no password needed for the candidate side). |
| Ashby | `jobs.ashbyhq.com` | Apply form → "Continue with Google" or plain email+CV. Guest OK. |
| Workable | `apply.workable.com` | "Apply now" → Google sign-in or email. **Known bug: 'Location (city)' autocomplete rejects typed/DOM values** (LinkedIn session 2026-09-07) → max 2 attempts, then skip + log `needs-review`. |
| SmartRecruiters | `jobs.smartrecruiters.com` | Account optional; Google/LinkedIn SSO or email+CV. OK. |
| JazzHR / BambooHR | `*.applytojob.com` / `*.bamboohr.com/careers` | Guest apply with email + CV usually OK. |
| iCIMS | `*.icims.com/jobs` | Often guest-apply with email; some require account + email OTP → if OTP wall: skip + log (no inbox automation). |
| Workday | `*.myworkdayjobs.com` / `*.wd3.myworkdaysite.com` | **Almost always requires account creation + email OTP.** If "Continue with Google" is available → use it. Else skip + log "Workday, no Google SSO". (Banks/enterprises: RBC/TD/Scotia/DBS/OCBC/UOB/Singtel/GIC etc.) |
| SuccessFactors / SAP | `*.successfactors.eu` / `*.successfactors.com` | Same as Workday: Google SSO if present, else skip + log. |
| Taleo / Oracle | `*.taleo.net` / `*.oraclecloud.com/hcm` | Same policy. |
| Indeed "Apply on company site" | redirects to any of the above | Follow the family policy. |
| Own-ATS (Shopify/Amazon/Microsoft/Google/TikTok etc.) | company careers domain | Try guest flow; Google SSO often accepted (MS/Google accounts). If account-only without Google → skip + log. |

**Rule of thumb:** any account creation flow that needs a password or an email OTP we cannot read → **skip + log**, never fabricate.

## 2. Google sign-in (the "signup" the candidate mentioned)

- Buttons to click, in order of appearance: "Continue with Google", "Sign in with Google", "Apply with Google", "Use Google".
- If a Google account chooser appears (multiple accounts) → pick the first account (the candidate's). If it shows "Choose an account" with one → click it. If it opens a password page → **stop, log "Google needs re-auth"** (the candidate's manual step), skip that job.
- Only click Google SSO on ATS domains of the company being applied to — never elsewhere.

## 3. Common field mapping (text → answers.md value)

| Field text | Answer |
|---|---|
| First/Last name | <FIRST NAME> / <LAST NAME> (exactly as on your CV) |
| Email | you@example.com |
| Phone | +10000000000 (or the local-format number when your country code is selected) |
| City / Location / Address | <YOUR CITY>, <YOUR COUNTRY> |
| Current company | <YOUR CURRENT EMPLOYER> |
| Current title | <YOUR CURRENT TITLE> |
| LinkedIn | linkedin.com/in/your-handle |
| GitHub/Portfolio | github.com/YOUR-GITHUB |
| Resume/CV upload | linkedin-automation/cv/CV.pdf |
| How did you hear about us? | LinkedIn / Company website (choose one present; else skip if required? best-guess "LinkedIn" acceptable — it is not a hard-stop category) |
| Notice period / start date | 30 days |
| Salary expectation (any currency) | answers.md §2 conversion table (floor USD <FLOOR_MONTHLY_USD>/mo) |
| Current compensation/CTC | answers.md §2 (current-comp conversions) |
| Work authorization / visa sponsorship | Per answers.md §2: Yes needs sponsorship (outside the authorised countries); authorized-to-work: No except the authorised countries — but SUBMIT unless explicit exclusion |
| "Will you relocate to X?" | Yes (any realistic country) |
| Years with AWS/Terraform/K8s/Docker/Jenkins/Linux/CI-CD/monitoring | Yes / per answers.md §2 |
| Valid passport | Yes |
| Languages | <LANGUAGES> |
| EEO/demographic (US/CA) | Decline-to-state where allowed; fill required only |
| Cover letter / "why us" | answers.md §3 templates; generic line with company name filled from the posting. If a required question has no bank answer → skip + log §5 |

## 4. Browser mechanics (learned from LinkedIn sessions — applies to all ATS)

- `browser action=open` a **labeled new tab** (`label: "fj-<country>-<company>"`) per company; never navigate existing tabs.
- After any navigation → snapshot that tab before acting. Use refs from the LATEST snapshot only.
- Synthetic `el.click()` is sometimes ignored by React apps → `scrollIntoView({block:'center'})` then real CDP `clickCoords` at element center.
- File uploads: use the upload action with the CV path against the file input ref when available (`paths` + `ref`/`inputRef`), else click the upload button then `browser action=upload`.
- Multi-page forms: after each Next/Review click → snapshot; watch for inline validation errors; if a page is stuck with no errors, the React tree may have crashed (check `browser action=errors`; known LinkedIn React #418) → reload the posting and restart the apply (answers often restore on later pages; refill phone/city).
- Radio groups: every required group must have a checked radio before advancing.
- Detect "already applied / submitted" states → skip silently (dedupe).
- When done with a company: `browser action=close` on that tab id (only tabs this run created).

## 5. Indeed (country sites) — Instant Apply & company-site apply

- Fresh labeled tab per country: `https://ca.indeed.com/jobs?q=devops+OR+cloud+OR+platform+engineer&l=&sort=date` (swap domain: `sg.`/`au.`/`uk.`/`ie.`/`de.`/`nl.`/`ae.`). Add `&fromage=3` (3 days) for freshness.
- Result card shows: "Apply on company site" (external ATS — follow family policy; the ATS URL is usually visible in the footer/link) or "Apply now" (Indeed Instant Apply — modal flow, contact + resume + screening Qs; same field mapping as §3; resume = CV.pdf).
- Screening questions inside Indeed Instant Apply behave like LinkedIn Easy Apply questions → answer from bank; unknown required → skip + log.
- Do NOT use pre-existing Indeed tabs (t24-t27 on 2026-09-07 looked human/in-progress) — always your own tab.
- After submit: confirmation page "Your application was sent". Log it.

## 6. Walls — recognize fast, skip fast (2 attempts max)

| Wall | Signature | Action |
|---|---|---|
| Workable location autocomplete | "Please enter a valid answer" on city even after typing/choosing | 2 tries → skip, log `needs-review` (draft may be saved for the candidate) |
| Right-to-work exclusion | "must be eligible/authorized…", "citizens/PR only", "no sponsorship", "not open to overseas" | skip immediately (guardrail §2.2) |
| Required skill not in bank | GitLab, ArgoCD, Python, Go, GCP/Azure arch cert, German etc. listed as requirement | skip immediately — never claim |
| Account-only ATS no Google SSO | OTP email prompt / create-password | skip + log |
| Captcha / Cloudflare / "Verify" | bot-check UI | skip + log, never fight |
| Salary below floor | posted range < answers.md floor (converted) | skip |
| Salary/gov/citizenship walls on SG gov | "Singaporeans only" | skip |

## 7. Reporting

End the run with the ≤180-word Telegram report (RULESET §5.8). Include anything the candidate must do manually (Google re-auth, account-only ATS the candidate wants to unlock, drafts saved needing the candidate to finish).
