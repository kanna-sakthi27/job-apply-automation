# ATS registry — append-only learned facts

> Copy to `ATS_REGISTRY.md`. Gitignored.

**Why it exists:** the expensive part of direct-ATS applying is rediscovering the same wall.
This file records, per company, what the last run actually found, so later runs stop
re-opening dead boards. It is the memory that turns a crawler into something that gets faster
over time.

```
company | country | board type | status | last seen | note
```

**Status values**

| Status | Meaning | Next run should |
|---|---|---|
| `applied-OK` | a real application was submitted here | keep the company in rotation |
| `needs-review` | form bug or unanswerable field | retry after N days |
| `wall-tool` | blocked by the ATS itself | retry only if it changes |
| `wall-404` | board gone | skip for N days |
| `wall-dns` | domain does not resolve | skip |
| `wall-redirect` | sends to an unexpected host | skip |
| `wall-ui` | unusable UI / no roles listed | skip |
| `no-roles` | board is live but nothing in scope | skip for N days |

**Rules**

1. Append-only, newest evidence wins.
2. Never re-open a `wall-*` company inside the cooldown window recorded here.
3. One row per company-country, updated rather than duplicated.

| Company | Country | Board type | Status | Last seen | Note |
|---|---|---|---|---|---|
| | | | | | |
