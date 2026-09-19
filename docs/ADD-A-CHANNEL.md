# Adding a channel — apply to any job site

Nothing in this repo is hardcoded to the seven channels it ships with. A channel is a **prompt**
plus **one config row**; the engine discovers the rest. Adding a site you have never automated takes
one command and one file to fill in.

## The four layers

Understanding this is the whole trick. Everything is one of:

| Layer | Where | Who edits it | How often |
|---|---|---|---|
| **Engine** | `tools/`, `prompts/_shared.md` | nobody | essentially never |
| **Registry** | `config/channels.conf`, `config/probes.conf` | one row per channel | when you add a channel |
| **You** | `bank/core.md` | you | once, then when facts change |
| **Channel** | `prompts/<ch>.md`, `<ch>-automation/RULESET.md` | you | when a site changes |

A run reads the engine, the registry row, your bank, and one channel prompt. That is the entire
input. So "support a new job site" is never a code change.

## Step 1 — scaffold

```bash
tools/new-channel.sh myboard --site myboard=https://www.myboard.com/ \
                             --schedule "0 10 * * *" --cap 20
```

That creates:

```
prompts/myboard.md                                  <- the runbook (fill this in)
myboard-automation/RULESET.md                       <- deep-dive notes (fill in as you learn)
myboard-automation/answers.md                       <- its run log (gitignored)
.commandcode/skills/myboard-job-apply/SKILL.md      <- loaded on demand by the agent
```

and appends one row to `config/channels.conf`.

## Step 2 — teach it the site

Open `prompts/myboard.md`. It is deliberately short: everything shared — browser discipline, the
never-do list, answer policy, budgets, logging, reporting — already comes from
`prompts/_shared.md`, and every form answer comes from `bank/core.md`. You only describe what is
true of **this** site:

- the URL to start from, and how to tell a real apply button from an external redirect
- the step order, and **how to recognise a step** (URL module, progress %, heading — never position)
- the trap that would otherwise burn a run: the modal that isn't a dialog, the reCAPTCHA that
  silently disables submit, the "save this draft?" interstitial
- the confirmation text that means a submission actually happened

That last one matters more than it looks: "count it only on the confirmation" is what keeps the
day cap honest.

## Step 3 — teach it how to detect login state

Copy the row pattern in `config/probes.conf`:

```
myboard|in=<text that only appears when signed in>|out=Sign in;/login|tab=<authenticated URL path>
```

- `in=` body text proving a session, `out=` text/paths proving a signed-out page, `tab=` URL paths
  of an already-open tab that prove a real session.
- **Only an `out=` match blocks a run.** Anything ambiguous is reported as `unknown` and the run
  proceeds — a false "signed out" stops you applying entirely, which is the expensive mistake.
- If you skip this step the probe reports "no probe rules" and never blocks, which is safe but
  blind. Worth two minutes.

## Step 4 — dry run, then run

```bash
tools/cron-run.sh myboard --dry-run   # pre-flight + prompt assembly, no model, zero tokens
tools/cron-run.sh myboard             # the real thing
```

`--dry-run` prints the assembled prompt size, the models, the caps, and the pre-flight result. Use
it whenever you change anything — it costs nothing and catches the two failure modes that otherwise
waste a whole run: the browser isn't attached, or the account is signed out.

## Step 5 — schedule it

```bash
tools/install-cron.sh --dry-run   # see the lines
tools/install-cron.sh             # install/refresh
```

It writes only its own marked block and leaves the rest of your crontab byte for byte alone.

## What actually went wrong in practice

Worth reading before you write your first prompt. Every one of these cost a real run:

- **The agent drove the wrong browser.** It silently launched its own bundled Chrome, saw a signed-out
  page, and reported "you are logged out" — for an account that was fine. `apply-preflight.sh` now
  proves the attachment by comparing CDP target ids before believing any login state, and blocks the
  run if they don't match. This is the single highest-value guard in the repo.
- **Step order varies per employer, even within one ATS.** Identify steps by structure, never position.
- **reCAPTCHA disables submit without saying so.** The form looks complete and the button is dead.
- **A false "signed out" is worse than a missed one.** Hence: only positive evidence blocks.
- **Boards serve different auth state per country host.** `ca.indeed.com` can be signed out while
  `indeed.com` is signed in; that's what `tab=` in `probes.conf` is for.
- **Never navigate a tab you didn't open.** It wedges the debugger and disturbs the human's session.

## Debugging a run

```bash
tools/jobs-status.sh                 # every channel: schedule, next run, today's count, last result
tools/jobs-status.sh --channel myboard
tools/cron-run.sh myboard --dry-run  # prompt + preflight, no spend
tail -f logs/myboard-<stamp>.log     # the full transcript of a run
tools/run-stats.sh --recent 12       # tokens and cost per run
```

`run-stats.sh` reads the CLI's session transcripts. Since a run re-reads its prompt on every turn,
the input column is dominated by prompt size — which is why the shared preamble exists and why the
bank is deliberately kept free of append-only history.

## Adapting this to something that isn't a job board

The engine is not job-specific. `cron-run.sh <name>` runs `prompts/<name>.md` headlessly under a
browser lock, with a pre-flight, a timeout, session resume across model switches, a log, token
accounting and a notification. Anything recurring that needs a logged-in browser fits:

1. `tools/new-channel.sh <name> --no-skill`
2. Write the prompt as a runbook: what to do, how to verify it worked, where to append state.
3. Set the cap to whatever "how many per day" means for you — the pre-flight uses it as the ceiling.

The part that makes it reliable is the same either way: **state lives in files the run appends to,
so the next run begins from what the previous one learned.**
