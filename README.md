# job-apply-automation

Unattended job-application automation: **cron schedules a channel, the Command Code CLI drives a
real logged-in browser, and every application is answered from an auditable answer bank.**

It runs 7 channels — LinkedIn, Indeed, Glassdoor, Jaabz and three foreign-direct blocks — on a
daily schedule, submitting real applications to DevOps / Cloud / SRE / Platform roles without a
human at the keyboard. Every run reports itself to Telegram, and every decision it made is in a
log file.

Built for one specific job search, then generalised into the template in front of you.

---

## The problem it solves

Applying at volume is not hard, it is just relentless: five boards, the same 30 questions, the
same resume upload, the same "why do you want to work here" box. Doing it by hand costs hours a
day. Doing it with a classic script means maintaining selectors against five happily-changing
front-ends, and a scraper that half-fills a form and gives up is worse than no scraper at all.

So the design choice here was **not** to script the DOM. It was to give an agent the same
instructions a careful human would use, and let it handle the variation:

- There is no selector list to maintain. Each channel has a **prompt** (a runbook) and a
  **ruleset** (the policy), both plain Markdown a human can read and correct.
- Where a form is unpredictable, the run does not guess — it **asks** (see *ask, don't skip*).
- Where it cannot proceed, it **skips and logs** rather than leaving a half-filled draft.

---

## How it works

```
                       ┌──────────────────────────────────────────┐
   crontab             │  tools/cron-run.sh <channel>             │
   06:00 glassdoor ───▶│                                          │
   07:00 linkedin      │  1. flock — ONE browser run at a time    │
   08:00 indeed        │  2. pre-flight: is Brave answering CDP?  │
   09:00 jaabz         │     (relaunch it if not)                 │
   10:00 foreign-CA    │  3. for each model in APPLY_MODELS:      │
       ...             │       free first; paid only if the       │
   23:00 foreign-rot   │       quota gate says the budget allows  │
                       │  4. timeout-guard each attempt           │
                       │  5. log to logs/<channel>-<stamp>.log    │
                       │  6. Telegram report either way           │
                       └───────────────────┬──────────────────────┘
                                           │ cmd -p prompts/<channel>.md
                                           │   --yolo --model <m>
                                           ▼
                       ┌──────────────────────────────────────────┐
                       │  headless agent run                      │
                       │    reads  → prompts/<ch>.md              │
                       │             <ch>-automation/RULESET.md   │
                       │             linkedin-automation/answers  │
                       │               .md §0  (authoritative)    │
                       │             applied-jobs-registry.md     │
                       └───────────────────┬──────────────────────┘
                                           │ agent-browser … (CDP 9222)
                                           ▼
                       ┌──────────────────────────────────────────┐
                       │  your real Brave, already logged in      │
                       │    LinkedIn · Indeed · Glassdoor · Jaabz  │
                       │    + company ATS (Greenhouse, Lever, …)  │
                       └───────────────────┬──────────────────────┘
                                           │
                                           ▼
                       append row → applied-jobs-registry.md  (dedupe)
                       append row → <ch>-automation/answers.md §6 (day cap)
                       Telegram   → "applied 12 · skipped 4 · …"
```

The important part is the arrow back into the registry: **the next run reads what the previous
runs wrote**, so state lives in files, not in the agent's memory.

---

## Components

| Path | What it is |
|---|---|
| `tools/cron-run.sh` | The launcher. Browser lock, CDP pre-flight, model fallback chain, per-attempt timeout, logging, Telegram report. |
| `tools/cc-quota` | Command Code quota checker. `--json` for machines, `--gate` exits 3 when the budget is spent. |
| `tools/tg-notify.sh` | Sends a Telegram message (stdin) to the configured chat. Never fails the caller. |
| `tools/jobs-status.sh` | Ops view: each channel's schedule, next run, last run result and last log line. |
| `prompts/<channel>.md` | The runbook the agent executes headlessly. Mission, guardrails, mechanics, reporting. |
| `<ch>-automation/RULESET.md` | The channel's policy: scope, hard guardrails, search strategy, runtime flow, failure modes. |
| `linkedin-automation/answers.md` | **Master answer bank.** §0 wins over every other file. |
| `<ch>-automation/answers.md` | Channel run log + channel-specific screener mapping. Also the day-cap counter. |
| `applied-jobs-registry.md` | Cross-channel dedupe source of truth. |
| `foreign-jobs-automation/ATS_PLAYBOOK.md` | Per-ATS mechanics: which boards allow guest apply, which need an account + OTP, which to skip. |
| `foreign-jobs-automation/ATS_REGISTRY.md` | Append-only "what we learned about this company's board", so runs stop re-opening dead ends. |
| `.commandcode/skills/` | Channel skills the agent loads on demand, so each run only pays for the context it needs. |

---

## Quick start

```bash
git clone git@github.com:<you>/job-apply-automation.git
cd job-apply-automation

# 1. secrets + channels
cp .env.example .env && chmod 600 .env     # Telegram bot token, chat id, models

# 2. answer bank — the only file you truly have to fill in
cp linkedin-automation/answers.example.md linkedin-automation/answers.md
cp applied-jobs-registry.example.md applied-jobs-registry.md
cp indeed-automation/answers.example.md  indeed-automation/answers.md
cp glassdoor-automation/answers.example.md glassdoor-automation/answers.md
cp jaabz-automation/answers.example.md   jaabz-automation/answers.md
cp foreign-jobs-automation/run-log.example.md foreign-jobs-automation/run-log.md
cp foreign-jobs-automation/ATS_REGISTRY.example.md foreign-jobs-automation/ATS_REGISTRY.md

# 3. your CV
cp <your-cv>.pdf cv/CV.pdf
mkdir -p linkedin-automation/cv && cp cv/CV.pdf linkedin-automation/cv/CV.pdf

# 4. browser: launch Brave with a debug port and log into the job boards once, by hand
brave-browser --remote-debugging-port=9222 --restore-last-session &

# 5. dry run a single channel
tools/cron-run.sh indeed

# 6. schedule it
crontab -e    # see the slots at the top of tools/cron-run.sh
```

`tools/jobs-status.sh` then shows every channel, when it next runs, and what happened last time.

---

## The five guardrails that make unattended applying safe

Handing an agent your logged-in browser and your career is only reasonable if it cannot
improvise. These five rules are what make the difference:

**1. Never invent facts.** Every answer comes from the answer bank. There is no "best guess" on a
real application — an invented visa status or years-of-experience figure is the one failure you
cannot undo. No answer in the bank → the job pauses, the run asks, and the run continues.

**2. Ask, don't skip.** A missing required answer used to mean an abandoned job. Now the run
messages the configured Telegram chat with the exact question text and options, logs it in §5,
continues with other jobs, and comes back if the answer arrives mid-run. Answers are then written
into the bank, so the question is only ever asked once.

**3. Dedupe before every submit.** Five channels advertise the same job. `applied-jobs-registry.md`
is greped for company + title keyword before submitting and appended after a confirmed submit —
otherwise the same employer receives five identical applications.

**4. Count only on confirmation.** "applied" means the confirmation page was seen. Everything else
is logged as skipped or needs-review with the reason. The day cap is derived from those rows, so
honest logging is what keeps the channel inside rate limits.

**5. Skip fast, log always.** Captcha, checkpoint, account-only ATS with no SSO, form bug after 3
attempts and one reload → skip, log, move on. A run that stalls on one bad form spends its whole
budget on nothing.

---

## Built with Command Code

Nothing here is a bespoke framework — the runner is a shell script and the agent is the
`cmd` CLI. What makes it work is how the CLI is used:

**A prompt is a program.** `cmd -p prompts/indeed.md --yolo` runs the runbook end to end with no
human in the loop (`--yolo`). Because the runbook is natural language, it survives the thing that
kills scrapers: the job boards redesigning. There is no selector to fix when Glassdoor renames a
CSS class — the prompt says *"the resume step, identified by the URL module and the progress
percentage"* and the agent re-finds it.

**Skills keep context — and cost — proportional.** The channel mechanics live in
`.commandcode/skills/*/SKILL.md`, which the agent pulls in only when it needs them. A run that
starts by loading every rulebook pays for every rulebook on every run.

**The model is pinned per run, and spend is gated.** `cron-run.sh` walks a model list: free
models (`*:free`) first, because they cost nothing, and a paid model only when
`tools/cc-quota --gate` says the weekly/monthly budget allows it. A run that would blow the
budget ends instead of spending. Quota is reported by the same script, never talked around.

**Unattended runs are still debuggable.** Every attempt is timeout-guarded and appended to
`logs/<channel>-<stamp>.log`, and the outcome is pushed to Telegram either way. When a run
misbehaves at 3am, the evidence is on disk — this matters more than it sounds, because the first
symptom of a provider change was an error message that named the wrong cause entirely (see
*Lessons*).

**One browser, one run.** `flock` serialises all channels. Job boards do not enjoy being driven
by two agents at once, and a single logged-in profile is the only reason the accounts stay
convincing.

### Why this shape is better than a conventional bot

| | Hand-rolled scraper | This |
|---|---|---|
| Board redesign | breaks, needs a code fix | prompt still describes the job to be done |
| Unknown question | crash, or invent an answer | asks, logs, continues |
| Cost control | whatever the API burns | free models first, paid gated on budget |
| Failure at 3am | stack trace in a log nobody reads | Telegram report + per-run log file |
| Auditing "why did it apply there?" | read the code | read the run log row |

---

## Lessons worth keeping

Collected the hard way, mostly from things that failed in production:

- **A provider error can name the wrong cause.** Runs failed for hours with
  `errorReason: context_overflow` while the actual 400 said
  `max_tokens (131072): Input should be less than or equal to 32768`. Payloads were 26–86 KB —
  nowhere near a real window. Diagnose from the raw provider error in the log, never the
  summarised failure reason.
- **Free tiers are flaky by design.** A `:free` model returning 429 bursts, and a fallback with a
  100-requests/day cap, will quietly break a fixed schedule. Know each model's limits before
  making it primary.
- **Step order varies by employer**, even within one ATS. Identify steps by URL module and
  progress percentage, never by position.
- **reCAPTCHA silently disables the Submit button.** The form looks complete; the button is
  disabled. Shields configuration is part of the automation, not an afterthought.
- **Some boards require a tab the run did not open.** Treat pre-existing tabs as the human's and
  never navigate them — the debugger wedges.
- **A "skipped" row is data, not a failure.** The reason recorded next to a skip is what stops the
  next run from making the same attempt.

---

## Per-channel docs

| Channel | Runbook | Policy | Notes |
|---|---|---|---|
| LinkedIn | `prompts/linkedin.md` | `linkedin-automation/RULESET.md` | Easy Apply modal, rate-limit safety |
| Indeed | `prompts/indeed.md` | `indeed-automation/RULESET.md` | the `smartapply` wizard in detail |
| Glassdoor | `prompts/glassdoor.md` | `glassdoor-automation/RULESET.md` | Easy Apply → the same Indeed wizard |
| Jaabz | `prompts/jaabz.md` | `jaabz-automation/RULESET.md` | aggregator; hands off to LinkedIn or the ATS |
| Foreign-direct | `prompts/foreign-*.md` | `foreign-jobs-automation/RULESET.md` | per-country; see `ATS_PLAYBOOK.md` |

---

## What is deliberately not in this repo

It is a template, not an archive. These hold real personal data and stay local — `.gitignore`
enforces it:

- `answers.md` and every channel's `answers.md` — the filled-in answer bank (name, phone, address,
  salary expectations, right-to-work status). Ship the `*.example.md` templates instead.
- `applied-jobs-registry.md`, `run-log.md`, `ATS_REGISTRY.md` — real application history.
- `cv/*.pdf` — the CV itself.
- `.env` — bot token, chat id, model list.
- `logs/` — run logs.

**Add your own before your first commit.** Fill in `linkedin-automation/answers.md` first: every
other file defers to it.

## Licensing

MIT — see [LICENSE](LICENSE).

## A word of caution

This automates your own accounts, in your own browser, with your own answers, and it submits on
your behalf. That is a real thing to point at a form. Keep the answer bank honest, keep the
"skip + log" rules intact, respect each site's terms and rate limits, and read a run's log before
you trust it with a channel you care about.
