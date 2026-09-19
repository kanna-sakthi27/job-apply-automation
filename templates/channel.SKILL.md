---
name: {{CHANNEL}}-job-apply
description: Apply to {{ROLE_SCOPE}} jobs on {{SITE}} for the operator against their real logged-in browser. Use when running or repairing the {{CHANNEL}} auto-apply channel.
---

# {{CHANNEL}} auto-apply ({{SITE}})

Use the `agent-browser` CLI against the operator's already-logged-in browser. Never log in,
never sign out, never clear cookies — a signed-out state is reported, not fixed.

## Read order

1. `bank/core.md` — the only source of form answers. Read it once.
2. `prompts/{{CHANNEL}}.md` — this channel's mechanics.
3. The pre-flight block already injected into the prompt (today's count, remaining budget,
   and the already-applied digest). **Do not read `applied-jobs-registry.md` yourself.**

Do not read this channel's `answers.md` / `run-log.md` in full — they are mostly append-only
history. You append to them; you do not read them for answers.

## Loop

1. `agent-browser connect <port>` — mandatory, every run.
2. Find or open a tab on `{{DOMAIN}}`.
3. Search → list jobs newest-first → filter by `bank/core.md` §1 scope.
4. Skip anything the pre-flight digest lists as already applied.
5. Apply, mapping every question to `bank/core.md`.
6. Count it only on the confirmation text. Append one log row. Append to the dedupe registry
   on a confirmed submit.
7. Close only the tabs you opened.

## Guards

- Scope, salary floor, sponsorship policy, and never-claim skills all come from `bank/core.md`.
- A required question with no bank answer → ask the operator, log it, continue with other jobs.
- Skip + log on walls; never leave a half-filled draft.
- Respect the per-run ceiling and the day cap in the pre-flight block.
