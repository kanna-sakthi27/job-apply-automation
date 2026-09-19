# Cross-channel applied-jobs registry

> Copy to `applied-jobs-registry.md`. This file is the **dedupe source of truth** for every
> channel and is gitignored — it is real application history.

**Why it exists:** the same job is advertised on LinkedIn, Indeed, Glassdoor, Jaabz and the
company's own ATS. Without a shared registry, five channels happily submit five identical
applications. Every run greps this file for company + title keyword **before** submitting and
appends a row **after** a confirmed submit.

```
date | title | company | channel | location | submitted
```

| Date | Title | Company | Channel | Location | Submitted |
|---|---|---|---|---|---|
| `YYYY-MM-DD` | `<job title>` | `<company>` | `linkedin / indeed / glassdoor / jaabz / foreign` | `<city, country>` | `yes` |

**Rules**

1. Append only — never rewrite or reorder history.
2. `submitted = yes` means the confirmation page was actually seen, not that a form was filled.
3. A row here is counted by the channel that created it; day caps are per channel, per day.
4. Match on company **and** title keyword — the same role usually ships under slightly different
   titles per board.
