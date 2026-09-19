# {{CHANNEL}}.md — {{SITE}} channel body (prepended by prompts/_shared.md)

One paragraph: what this channel applies through, and the one rule that matters most.
Keep this file SMALL — everything shared (browser rules, answer policy, budgets, logging)
already lives in `prompts/_shared.md`, and every answer comes from `bank/core.md`.
Only put things here that are true of THIS site.

You are the {{SITE}} auto-apply run. Apply via **{{APPLY_MODE}}** only.

## Tab handling

`agent-browser tab list` → switch to the tab whose URL contains `{{DOMAIN}}`
(`agent-browser tab <n>`), and do every action on that tab. If none exists, open one:
`agent-browser open {{SEARCH_URL}}`.
If Brave is not running or no tabs come back → report "browser unavailable" and quit.

## Finding the apply button — and the trap that wastes the run

1. `<describe the click path from search results to the apply button>`
2. `<how to tell an on-site apply from an external one>` — external apply is SKIP + log.
3. `<what the button looks like in the DOM if it is not what it claims to be>`
4. ANTI-SPIN: max ~2 minutes / 3 attempts per job. Still not found → SKIP + log, next job.

## Known gotchas (do not rediscover these)

- `<the one that breaks every run: modal that isn't a dialog, reCAPTCHA disabling
  submit, a step order that changes per employer, a stale draft interstitial…>`
- `<a second one>`

## Form filling

Map every question to `bank/core.md`. Salary → the bank's conversion table for the
posting's country. Notice/start date/authorisation → the bank. A required question with no
bank answer → ask (shared preamble), never invent.

After submit, wait for the confirmation text (`{{CONFIRMATION_TEXT}}`) before counting it as
applied, then log it per STATE in the shared preamble.

## Markets / searches

`<keyword rotation and country/market rotation for this board; if the board is
single-market, say so and give the filters (newest-first, remote filter, etc.)>`
