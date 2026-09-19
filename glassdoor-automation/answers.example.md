# Glassdoor — answer bank (channel copy)

> Copy to `answers.md`. Identity and salary answers live in the master bank
> (`linkedin-automation/answers.md` §0).

## §1 — Channel-specific mechanics

- Glassdoor "Easy Apply" is Indeed-powered: clicking it opens the **same
  `smartapply.indeed.com` wizard** in a new tab.
- The resume used is the one on the **Indeed profile**, so it must already be uploaded there
  and pre-selected on the resume step.
- Easy Apply does not require a Glassdoor login — it runs on the Indeed session.
- Brave Shields must be down for `smartapply.indeed.com`, `indeed.com`, `glassdoor.com`,
  `recaptcha.net` and `gstatic.com`, or the Submit button stays disabled.

## §2 — Screener mapping

Identical to `indeed-automation/answers.example.md` §2 — the wizard is the same code.

## §3 — Salary conversions

Use the master §2 conversion table (annual figure for the posting's country, currency set via
the combobox).

## §5 — Unanswered questions

| Date | Job | Question | Options | Status |
|---|---|---|---|---|
| | | | | |

## §6 — Run log (day-cap counter)

```
date | title @ company, country | applied / skipped / needs-review | note
```

| Date | Job | Outcome | Note |
|---|---|---|---|
| | | | |
