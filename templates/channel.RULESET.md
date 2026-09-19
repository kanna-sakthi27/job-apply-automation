# {{SITE}} — deep-dive notes for the {{CHANNEL}} channel

> Channel deep-dive: site mechanics and hard-won history. The runbook that actually executes
> is `prompts/{{CHANNEL}}.md` + `prompts/_shared.md`, and **every form answer comes from
> `bank/core.md`**.

Fill this in as you learn the site. It is the file that stops the next run from repeating a
mistake you already paid for. Sections that matter:

## 1. Apply path

- URL shape of a job posting: `<...>`
- The apply control, and how to tell it from an external redirect: `<...>`
- Step order, and how you identify a step (URL module, progress %, heading — never position).

## 2. Hard guardrails (never cross)

1. Never invent a fact — answers come from `bank/core.md`.
2. Anti-spin: 3 attempts / ~2 minutes per job, then skip + log.
3. One job at a time; let each form settle before the next action.
4. Skip + log on: captcha/checkpoint, account-only flow with no SSO, form bug after one reload,
   or a posting the bank lists as a wall.
5. Never log in, never sign out, never clear cookies — report "needs the operator" instead.

## 3. Walls seen here

| Symptom | What it means | Action |
|---|---|---|
| `<symptom>` | `<cause>` | skip + log |

## 4. Failure modes

| Symptom | Action |
|---|---|
| `<symptom>` | `<action>` |

## 5. State

- Day cap: `config/channels.conf` (and the pre-flight block tells you today's count).
- This channel's log: `<log path from channels.conf>` §6 — append one row per job.
- The cross-channel dedupe registry is `applied-jobs-registry.md`.
