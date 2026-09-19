# job-apply-automation

Unattended job-application automation: **cron schedules a channel, the Command Code CLI drives a
real logged-in browser, and every application is answered from one auditable file you control.**

It ships with 7 working channels (LinkedIn, Indeed, Glassdoor, Jaabz and three foreign-direct
blocks) — but nothing in the engine is specific to them. **Adding a job site you've never automated
is one command and one prompt file**, because a channel is a prompt plus a config row, not code.

Built for one specific job search, then generalised into the template in front of you.

---

## The problem it solves

Applying at volume is not hard, it is just relentless: several boards, the same 30 questions, the
same resume upload, the same "why do you want to work here" box. Doing it by hand costs hours a day.

Doing it with a classic script means maintaining selectors against several happily-changing
front-ends, and a scraper that half-fills a form and gives up is worse than no scraper at all.

So the design choice here was **not** to script the DOM. It was to give an agent the same
instructions a careful human would use, and let it absorb the variation:

- No selector list to maintain. A channel is a **runbook** (prompt) plus a **ruleset** (policy),
  both plain Markdown you can read and correct.
- Where a form is unpredictable, the run does not guess — it **asks**.
- Where it cannot proceed, it **skips and logs** rather than leaving a half-filled draft.

---

## How it works

```
   crontab                    tools/cron-run.sh <channel>
   (from channels.conf)              │
   06:00 glassdoor ──────────────────┤  1. flock — ONE browser run at a time
   07:00 linkedin                    │  2. tools/apply-preflight.sh  (shell only, ZERO tokens)
   08:00 indeed                      │       · Brave reachable on CDP?
   09:00 jaabz                       │       · is agent-browser attached to it (not its own Chrome)?
   ...                               │       · is the account still signed in?
                                     │       · how many already submitted today → remaining budget
                                     │       · digest of every job already applied to, any channel
                                     │     exit 3 = blocked before spending a single token
                                     │  3. compose the prompt:
                                     │       prompts/_shared.md + preflight block + prompts/<ch>.md
                                     │  4. walk the model list — free first, paid only if the
                                     │     quota gate allows; a retry RESUMES the same session
                                     │  5. token + cost accounting (tools/run-stats.sh)
                                     │  6. Telegram report either way
                                     ▼
                          cmd -p <prompt> --yolo --max-turns N -n <session> --model <m>
                                     │
                          agent-browser … (CDP, your real browser)
                                     ▼
                          LinkedIn · Indeed · Glassdoor · Jaabz · company ATS
                                     │
                                     ▼
                          append → applied-jobs-registry.md      (cross-channel dedupe)
                          append → <ch>-automation/answers.md §6 (day-cap counter)
                          Telegram → "applied 12 · skipped 4 · …"
```

The important part is the arrow back into the registry: **the next run reads what the previous runs
wrote**, so state lives in files, not in the agent's memory.

---

## The four layers

Everything is one of these. Knowing which is which is the whole trick.

| Layer | Where | You edit it | How often |
|---|---|---|---|
| **Engine** | `tools/`, `prompts/_shared.md` | never | — |
| **Registry** | `config/channels.conf`, `config/probes.conf` | one row per channel | when adding a channel |
| **You** | `bank/core.md` | **yes — this is the file** | once, then when facts change |
| **Channel** | `prompts/<ch>.md`, `<ch>-automation/RULESET.md` | per site | when a site changes |

A run reads the engine, one registry row, your bank, and one channel prompt. That is the entire
input — so supporting a new job site is never a code change.

| Path | What it is |
|---|---|
| `tools/cron-run.sh` | The launcher. Browser lock, pre-flight, prompt assembly, model fallback with session resume, timeout, logging, report. Channel-agnostic. |
| `tools/apply-preflight.sh` | Zero-token pre-flight. Blocks the run if the browser isn't attached, the account is signed out, or the day cap is already hit. |
| `tools/run-stats.sh` | Tokens and cost per run, read from the CLI's session transcripts — proof a change actually saved money. |
| `tools/new-channel.sh` | Scaffolds a new channel from `templates/`. One command. |
| `tools/install-cron.sh` | Turns the schedule column into crontab lines, touching only its own marked block. |
| `tools/jobs-status.sh` | Every channel: schedule, next run, today's count, last result. |
| `tools/cc-quota` | Quota checker/gate. `--gate` exits 3 when the budget is spent. |
| `tools/tg-notify.sh` | Sends a Telegram message. Never fails the caller. |
| `prompts/_shared.md` | The preamble prepended to every channel prompt: browser discipline, answer policy, budgets, logging. |
| `prompts/<ch>.md` | One channel's runbook. Deliberately short. |
| `bank/core.md` | **All form answers.** §0-equivalent authority over every other file. |
| `config/channels.conf` | The channel registry: schedule, log, day cap, login probes. |
| `config/probes.conf` | Per-site signed-in / signed-out signals. |
| `applied-jobs-registry.md` | Cross-channel dedupe source of truth. |

---

## Prerequisites

Verified against the setup this was built on (Linux x86_64):

| Requirement | Why | Check |
|---|---|---|
| **Command Code CLI**, signed in | Runs the agent. `npm i -g command-code`, then run `cmd` once to sign in. | `cmd --version` |
| **A plan with credits** | GOAT is what this runs on — see below. Free models cost $0, so routine runs barely touch it. | `tools/cc-quota` |
| **Node.js + npm** | Installs the CLI and `agent-browser`. | `node --version` |
| **`agent-browser` CLI** | Drives the browser over CDP. `npm i -g agent-browser && agent-browser install` | `agent-browser --version` |
| **A Chromium browser** (Brave or Chrome) started with `--remote-debugging-port=9222` | It must be *your* logged-in profile — the whole approach depends on real sessions. | `curl -s 127.0.0.1:9222/json/version` |
| **Python 3** | The pre-flight, stats and status tools parse JSON with it. | `python3 --version` |
| **bash, flock, curl, timeout, crontab** | Browser locking, pre-flight HTTP, per-attempt timeouts, scheduling. | `flock --help` |
| **Telegram bot token + chat id** (optional) | Where "I need an answer" questions and run reports go. Skip it and log to a file instead. | message your bot once |
| **Your CV as a PDF** | Uploaded on every form. | `ls cv/CV.pdf` |

Two things that save time:

- **`flock` is Linux.** On macOS it isn't there by default — `brew install flock`, or swap the lock in
  `cron-run.sh` for an `mkdir` lock. Everything else is portable.
- **Log in once, by hand.** The automation never authenticates: it reports "needs the operator to
  sign in" rather than trying. Start the browser with the debug port, sign into each board, then
  leave that profile alone.

## Quick start

```bash
git clone git@github.com:<you>/job-apply-automation.git
cd job-apply-automation

# 1. secrets
cp .env.example .env && chmod 600 .env

# 2. THE file — every answer comes from here
cp bank/core.example.md bank/core.md && $EDITOR bank/core.md

# 3. state files the prompts reference
cp linkedin-automation/answers.example.md linkedin-automation/answers.md
cp indeed-automation/answers.example.md   indeed-automation/answers.md
cp glassdoor-automation/answers.example.md glassdoor-automation/answers.md
cp jaabz-automation/answers.example.md    jaabz-automation/answers.md
cp foreign-jobs-automation/run-log.example.md foreign-jobs-automation/run-log.md
cp foreign-jobs-automation/ATS_REGISTRY.example.md foreign-jobs-automation/ATS_REGISTRY.md
cp applied-jobs-registry.example.md applied-jobs-registry.md

# 4. your CV
cp <your-cv>.pdf cv/CV.pdf
mkdir -p linkedin-automation/cv && cp cv/CV.pdf linkedin-automation/cv/CV.pdf

# 5. browser: start it with a debug port, then log into the boards ONCE, by hand
brave-browser --remote-debugging-port=9222 --restore-last-session &

# 6. prove the pipeline works without spending anything
tools/cron-run.sh selftest --dry-run
tools/cron-run.sh selftest

# 7. a real channel, dry first
tools/cron-run.sh indeed --dry-run
tools/cron-run.sh indeed

# 8. schedule it
tools/install-cron.sh --dry-run && tools/install-cron.sh
```

`tools/jobs-status.sh` then shows every channel and what happened last time.

### Add a job site that isn't in here

```bash
tools/new-channel.sh myboard --site myboard=https://www.myboard.com/ --schedule "0 10 * * *"
$EDITOR prompts/myboard.md      # only the site-specific bits
tools/cron-run.sh myboard --dry-run
```

Full walkthrough, including how to teach it login detection and what to put in the prompt:
**[docs/ADD-A-CHANNEL.md](docs/ADD-A-CHANNEL.md)**.

---

## The guardrails that make unattended applying safe

Handing an agent your logged-in browser and your career is only reasonable if it cannot improvise.

**1. Never invent facts.** Every answer comes from `bank/core.md`. There is no "best guess" on a real
application — an invented visa status or years-of-experience figure is the one failure you cannot
undo.

**2. Ask, don't skip.** A missing required answer messages you with the exact question text and
options, logs it, and the run carries on with other jobs. Answers then get written into the bank, so
a question is only ever asked once.

**3. Dedupe before every submit.** Several channels advertise the same job. The pre-flight injects
the already-applied digest into the prompt, so a run doesn't even have to look it up — and the
registry is appended after every confirmed submit.

**4. Count only on confirmation.** "applied" means the confirmation text was seen. Everything else is
logged as skipped with the reason. The day cap is derived from those rows, so honest logging is what
keeps the channel inside rate limits.

**5. Skip fast, log always.** Captcha, checkpoint, account-only ATS, form bug after one reload →
skip, log, move on. A run that stalls on one bad form spends its whole budget on nothing.

**6. Block before spending.** The pre-flight runs in pure shell. If the browser isn't attached or the
account is signed out, the run exits with code 3 **before the model starts** — the failure that used
to cost a 45-minute run now costs nothing.

---

## Built with Command Code

The runner is a shell script and the agent is the `cmd` CLI. What makes it work is how the CLI is
used:

**A prompt is a program.** `cmd -p prompts/indeed.md --yolo` runs the runbook end to end with no
human in the loop. Because the runbook is natural language, it survives the thing that kills
scrapers: the front-end changing. There is no selector to fix when a board renames a CSS class — the
prompt says *"identify the step by URL module and progress percentage"* and the agent re-finds it.

**A model switch resumes, it doesn't restart.** `-n <session>` names the session; `--resume` picks it
back up. When a throttled free model times out or hits the turn cap, the next model inherits
everything already done instead of redoing a half-finished application. The turn cap (exit 8) is
treated as partial success and resumed, not thrown away.

**Skills keep context — and cost — proportional.** Channel mechanics live in
`.commandcode/skills/*/SKILL.md` and are loaded only when relevant. A run that loads every rulebook
pays for every rulebook on every run — which is also why the shared preamble exists and why the bank
is kept free of append-only history.

**Spend is gated, and measured.** `cron-run.sh` walks a model list: `*:free` first, because they cost
nothing, and a paid model only while `tools/cc-quota --gate` says the budget allows it. Then
`tools/run-stats.sh` reports tokens and cost per run from the session transcripts, so "this change
made runs cheaper" is a number, not a feeling.

**Unattended runs stay debuggable.** Every attempt is timeout-guarded and appended to
`logs/<channel>-<stamp>.log`, and the outcome goes to Telegram either way. That matters more than it
sounds — see the first lesson below.

### What it runs on: the Command Code GOAT plan

This project runs on the **GOAT plan**: **$10/month that buys $70 of model usage** — a 7× multiplier —
with rolling burst guards of **$14 per 5 hours** and **$35 per week** on top of the monthly pool.

That shape matters more than the headline number here, because applying to jobs is *routine* work:

- **Free models cost $0.** `laguna-s-2.1-free` and `ling-3.0-flash-sante:free` bill at zero and don't
  draw down any allowance — so a day of scheduled runs on the free tier can cost nothing at all.
- **The paid fallback is gated, not hopeful.** `cron-run.sh` only reaches for a paid model while
  `tools/cc-quota --gate` says the budget allows it, so one throttled free model can't quietly spend
  your month.
- **Rolling windows suit cron.** Many small runs spread across a day are exactly what a 5-hour and
  weekly window is designed to smooth; they exist so a burst can't drain the month.
- **Usage is measured, not assumed.** `tools/run-stats.sh` reads the session transcripts, so "this
  change made runs cheaper" is a number.

GOAT includes 52 of the 72 catalog models, API access on the same key, and the free models above.
If a run ever does exhaust the plan, paid models pause until the window resets while the free models
keep working — a far better failure mode for an unattended job than a hard stop.

### How this compares to the other ways of doing it

The honest version: the alternatives are all reasonable, and each is worse at one specific thing this
project needs — applying unattended, from your own logged-in sessions, at a predictable cost.

| Approach | The trade-off |
|---|---|
| **Selector-driven scripts** (Playwright/Selenium) | Cheapest per run and fully deterministic, but every redesign is a code fix, and "if you can't answer this, ask me" has to be written by hand. |
| **Your own LLM loop against a model API** | Maximum control — but you build the agent loop, browser tooling, retries, session continuity and budget guardrails. That's most of this repo, reimplemented. |
| **Hosted / cloud browser agents** | Nothing to run, and good for isolated scraping — but they don't use *your* logged-in job-board sessions, and your form answers leave your machine. |
| **AI autofill extensions** | Genuinely useful, and human-in-the-loop by design — which is the opposite of unattended. |
| **This: headless agent runs on your own browser** | Natural-language runbooks that survive redesigns, your real sessions, files as the state store, per-run cost accounting — at the price of a plan with credits and a browser left running. |

Two deliberate trade-offs: it wants a plan with credits for the fallback path, and it needs a browser
holding your real logins. Everything else follows from those two choices.

### What the CLI gives this project that a bare API call wouldn't

- **Headless mode built for cron.** `cmd -p` puts the answer on stdout, progress on stderr, and
  signals failure with real exit codes (3 = not authenticated, 5 = rate limited, 8 = max turns). That
  is why the launcher can tell "out of turns, keep the work" apart from "model failed, try another".
- **Permissions as a flag.** A headless run blocks file writes and shell by default; `--yolo` is an
  explicit, auditable opt-in per run rather than a standing config.
- **Skills on demand.** Channel mechanics load only when relevant, so context — and therefore cost —
  stays proportional to the job at hand.
- **Session resume.** `--resume <id>` means a model switch or a turn-cap hit continues a half-finished
  application instead of redoing it.
- **Everything is scriptable.** `--config key=value` reaches any setting the interactive UI can, so a
  run is fully described by its command line and nothing lives in hidden state.
- **Project memory in the repo.** `AGENTS.md` and the skills travel with the code, so the project
  carries its own operating rules.

### Why this shape beats a conventional bot

| | Hand-rolled scraper | This |
|---|---|---|
| Site redesign | breaks, needs a code fix | prompt still describes the job to be done |
| New job site | new scraper | `tools/new-channel.sh` + one prompt |
| Unknown question | crash, or invent an answer | asks, logs, continues |
| Signed-out / wrong browser | burns the run, reports nonsense | blocked in shell before the model starts |
| Cost control | whatever the API burns | free models first, paid gated on budget |
| "Why did it apply there?" | read the code | read the run log row |

---

## Lessons worth keeping

Collected the hard way, mostly from things that failed in production:

- **An error can confidently name the wrong cause.** Runs failed for hours with
  `errorReason: context_overflow` while the actual 400 said
  `max_tokens (131072): Input should be less than or equal to 32768`. Payloads were 26–86 KB —
  nowhere near a real window. Diagnose from the raw provider error, never the summarised reason.
- **The agent will happily drive the wrong browser.** Without an explicit attach, it launches its own
  bundled Chrome, sees a signed-out page, and reports "you are logged out" for a healthy account.
  Comparing CDP target ids *before* believing any login state is the highest-value guard here.
- **A false "signed out" costs more than a missed one.** Only positive evidence blocks a run.
- **Boards serve different auth state per country host.** `ca.indeed.com` can be signed out while
  `indeed.com` is signed in — so an already-open authenticated tab outranks a probe.
- **Free tiers are flaky by design.** A `:free` model returning 429 bursts, and a fallback with a
  100-requests/day cap, will quietly break a fixed schedule.
- **Step order varies by employer**, even within one ATS. Identify steps by structure, not position.
- **reCAPTCHA silently disables submit.** The form looks complete; the button is dead.
- **A "skipped" row is data, not a failure.** The reason recorded next to a skip is what stops the
  next run from making the same attempt.

---

## Per-channel docs

| Channel | Runbook | Deep-dive |
|---|---|---|
| LinkedIn | `prompts/linkedin.md` | `linkedin-automation/RULESET.md` |
| Indeed | `prompts/indeed.md` | `indeed-automation/RULESET.md` |
| Glassdoor | `prompts/glassdoor.md` | `glassdoor-automation/RULESET.md` |
| Jaabz | `prompts/jaabz.md` | `jaabz-automation/RULESET.md` |
| Foreign-direct | `prompts/foreign-*.md` | `foreign-jobs-automation/RULESET.md` + `ATS_PLAYBOOK.md` |
| *(self-test)* | `prompts/selftest.md` | drives the pipeline test, never touches a board |

The rulesets are the channel **deep-dives** — site mechanics and hard-won history, including notes
from earlier incarnations of the system. The runbook that actually executes is
`prompts/<channel>.md` + `prompts/_shared.md`, and every form answer comes from `bank/core.md`.

---

## What is deliberately not in this repo

It is a template, not an archive. These hold real personal data and stay local — `.gitignore`
enforces it:

- `bank/core.md` — **the filled-in answer core**: name, phone, address, work-authorisation status,
  salary expectations, employers. `bank/core.example.md` is the template.
- `answers.md` and each channel's `answers.md` — run logs and unanswered questions.
- `applied-jobs-registry.md`, `run-log.md`, `ATS_REGISTRY.md` — real application history.
- `cv/*.pdf` — the CV itself.
- `.env` — bot token, chat id, model list.
- `logs/` — run transcripts.

Fill in `bank/core.md` before your first run: every other file defers to it.

## Licensing

MIT — see [LICENSE](LICENSE).

## A word of caution

This automates your own accounts, in your own browser, with your own answers, and it submits on your
behalf. That is a real thing to point at a form. Keep the bank honest, keep the "skip + log" rules
intact, respect each site's terms and rate limits, and read a run's log before you trust it with a
channel you care about.
