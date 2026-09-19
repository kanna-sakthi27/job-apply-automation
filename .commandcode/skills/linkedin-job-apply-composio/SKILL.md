---
name: "linkedin-job-apply-composio"
description: "Apply to LinkedIn jobs for the candidate via the Composio CLI: verify connection, search jobs, present matches, apply only on approval."
---

# LinkedIn Job Apply via Composio CLI

Apply to LinkedIn jobs for **the candidate** using the agent-browser CLI against the candidate's Brave browser. Use this skill whenever the candidate asks to find/apply to jobs on LinkedIn.

## Standing decisions from the candidate

- **Submit mode:** full auto-submit (no per-job checkpoint).
- **Target roles only:** titles containing `DevOps Lead`, `Cloud Manager`, `DevOps Manager`, `Head of DevOps`, `Cloud Lead`, `Platform Lead`, `SRE Lead`, `Infrastructure Lead`, `Cloud Infrastructure Lead`, or similar leadership/management terms.
- **Skip:** generic `Senior DevOps Engineer`, `DevOps Engineer`, `SRE`, `Platform Engineer` unless the title also contains Lead/Manager/Head/Principal/Director/VP.
- **Answers file:** `workspace/answers.md` stores contact info, salary, notice, and best-guess answers. Read it before applying.

## Account state (verify each session)

- Brave must be running with CDP on `http://127.0.0.1:9222`. Attach with `agent-browser connect 9222` (the launcher pre-checks this; if Brave is down it relaunches it with `--remote-debugging-port=9222`).
- Composio CLI is available for a LinkedIn smoke test (`composio execute LINKEDIN_GET_MY_INFO -d '{}'`).
- LinkedIn connection: **`linkedin_enrage-clan`** (ACTIVE).

## Workflow

### 1. Verify Brave is attached
```
browser action=status profile=brave
```
If `cdpReady` is false, kill/relaunch Brave with `--remote-debugging-port=9222 --restore-last-session` as your desktop user, then retry.

### 2. Verify a live tool call (optional smoke test)
```bash
composio execute LINKEDIN_GET_MY_INFO -d '{}'
```
Note: repeated identity lookups can hit 429 daily limits — call once per session max.

### 3. Search jobs in Brave
- Use `browser action=navigate` with a LinkedIn Jobs search URL, e.g.:
  - `https://www.linkedin.com/jobs/search/?f_AL=true&keywords=DevOps%20Lead&location=Singapore&sortBy=DD`
  - Try variants: `Cloud Manager`, `DevOps Manager`, `Platform Lead Infrastructure`, etc.
- Filter is already set to **Easy Apply** (`f_AL=true`).
- Sort by **Most recent** (`sortBy=DD`).

### 4. Select matching roles
- Prefer titles that match the standing targeting rules above.
- Avoid listings marked "USC only", "US citizens only", or obviously mismatched locations unless the candidate says otherwise.
- **Check for an existing application before applying:** once the job page loads, look for "Application submitted" / "anda memohon" in the body, or an action button that reads "Continue" instead of "Easy Apply". Many qualifying roles are already applied from earlier rounds — skip those without re-opening Easy Apply.

### 5. Apply
- Click the job title to open the detail pane, then click the **Easy Apply** button.
- Fill from `answers.md` / best guess:
  - **Phone:** `+10000000000` (use `00000000000` when your country code is already selected).
  - **Location (city):** `<YOUR CITY>` / `Greater <YOUR CITY>`.
  - **Resume:** select the latest PDF resume already uploaded to LinkedIn.
  - **AWS experience years:** 9 years AWS, 7 years S3, 7 years RDS (or best-guess from profile).
- Answer additional screening questions truthfully/best-guess from profile.
- For US roles, expect EEO/demographic questions; fill required fields and select "I decline to say" where allowed.
- Submit without asking for per-job approval.

### 5b. If the apply modal is stuck (clicks do nothing)

- Before anything: confirm the browser is actually attached — `browser action=status profile=brave` needs `cdpReady:true` + `pageReady:true`. If `running:false`, Brave was started WITHOUT `--remote-debugging-port=9222`. Relaunch: `su - "$USER" -c 'export DISPLAY=:0; nohup brave-browser --remote-debugging-port=9222 --restore-last-session >/tmp/brave-debug.log 2>&1 &'`. Your desktop user's Brave launcher `$HOME/.local/share/applications/brave-browser.desktop` already carries the flag — never put it in root's dir (Brave runs as your desktop user).
- **Never `navigate` a busy/wedged tab** (hangs 65s+). Instead `open` a fresh labeled tab with the URL, or recover in-place with `location.reload()` via `act evaluate`.
- The Easy Apply modal often has **no `role=dialog`** — find it as the `div` whose `innerText` starts with `Apply to <Company>`. Read progress from `(\d+)/7 pages` and the footer buttons (Back / Next / Review / Submit).
- If a **"Save this application?"** interstitial appears, a draft exists from an earlier attempt → click **Save**, then click **Continue** on the job page (it's an `<a>`, NOT a `<button>` — `querySelectorAll('a')` must include it). The draft restores contact/resume; phone may come back truncated (e.g. `0000000000` missing leading `0`) → refill `00000000000`.
- Synthetic `el.click()` is sometimes ignored by LinkedIn's React; if nothing happens, `scrollIntoView({block:'center'})` the target then use a **real CDP click at coordinates** (`act` kind `clickCoords` with the element center). In the modal footer the Submit button sits around x≈1255, y≈773 after scrolling.
- If the form is fully valid (no inline error text, every radio group has a checked radio) but Next/Review does nothing, the page's React tree crashed — confirm with `browser action=errors` (Minified React error #418, or `Cannot read properties of null (reading 'entityUrn')`).
- Recovery: reload the clean job URL, then click **Easy Apply** again. LinkedIn restores saved answers on later pages, but phone/city come back empty — refill `00000000000` (Malaysia already selected) and `<YOUR CITY>`, then advance.
- Audit unanswered questions with a small `act evaluate`, not full snapshots: for each `fieldset` count checked radios, list required-but-empty inputs. Full-page snapshot churn can stall LinkedIn further.
- Work-authorization reality check: for US-based roles, the form asks "authorized to work in US without sponsorship". the candidate is based in <YOUR COUNTRY> → answer truthfully (No) and abandon that application; don't waste the round. Prefer SG/MY/global-remote postings.

### 6. Track
- Log each applied/skipped job with company, title, URL, and timestamp in the daily memory note and/or workboard.
- If the browser connection drops mid-apply, note the exact step and resume on reconnect.

### 7. Report
- Send a concise summary to the candidate's preferred channel (Telegram/WhatsApp) with: jobs applied, jobs in progress, jobs skipped, and any blockers.

## Gotchas (learned the hard way)

- `composio link` / `connections remove` are **interactive** → use `pty=true` or they get killed.
- Re-login: **log out old sessions first** (`composio logout`), then `composio login` → the candidate opens the URL (10-min expiry!) → `composio login --poll`.
- Project API key (`ak_...`) is SDK-only; do not attempt CLI login with it.
- Some tools require explicit data payloads (`-d '{}'` or `--get-schema` output) — if you see "Invalid JSON input", pass `-d '{}'` first, then check the schema.

## Token-efficiency rules

- `jq` every API response to the fields needed.
- One `composio run` workflow instead of N sequential `composio execute` calls.
- Keep the digest/apply replies under ~150 words unless the candidate asks for detail.
