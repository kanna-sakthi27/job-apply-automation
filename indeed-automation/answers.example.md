# Indeed — answer bank (channel copy)

> Copy to `answers.md`. Identity and salary answers live in the master bank
> (`linkedin-automation/answers.md` §0) — do not duplicate them here, link to them.

## §1 — Channel-specific mechanics

- Apply flow opens in a **new `smartapply.indeed.com` tab**, not an iframe.
- Step order varies by employer; identify each step by URL module + progress percentage.
- Profile values the wizard prefills come from the Indeed profile, not from this file —
  verify them rather than trusting them (a stale country code on the phone field is the
  single most common silent failure).
- Invisible reCAPTCHA sometimes aborts the anchor on first load and the review page hangs on
  "Preparing review" → reload the tab once and re-walk; answers persist.

## §2 — Screener mapping

Map each `fieldset` legend to a master-bank answer by keyword. Guarantee every required radio
group is answered and no element carries `aria-invalid=true` before clicking Continue.

| Screener keyword | Answer source |
|---|---|
| previously employed / worked here before | master §0 eligibility |
| legally eligible / authorised to work in `<country>` | master §2 visa phrasing |
| require sponsorship | master §2 visa phrasing |
| background check | master §0 |
| convicted / criminal record | master §0 |
| referral / related to an employee | master §0 |
| accommodation | master §0 |
| preferred language | master §0 languages |
| notice period | master §0 |
| how did you hear about us | `<channel default>` |
| salary expectation | master §2 conversion table |

## §4 — Free text

Use master §3 templates. Required free text with no template → ask (§5), do not invent.

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
