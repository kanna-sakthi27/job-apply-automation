# Answer bank — MASTER (§0 is authoritative for every channel)

> Copy to `answers.md` and fill in. `answers.md` is gitignored on purpose.
>
> **This file is the single source of truth.** Every channel prompt (LinkedIn, Indeed,
> Glassdoor, Jaabz, foreign-direct) reads it, and §0 wins over any other file — including the
> prompts themselves. If a required question has no answer here, the run must **ask, not guess**
> (§5), never invent a value.
>
> Two rules that keep the whole system honest:
>
> 1. **Never invent facts.** No answer here → ask (§5) or skip the job. Fabricating a value on a
>    real application is the one unrecoverable failure mode.
> 2. **Numeric screeners are floats, not integers.** If you have 9.5 years, answer a "years of
>    experience" dropdown with the value that is truthful but not understated. Decide this once,
>    here, so twenty runs a day stay consistent.

---

## §0 — Identity, authorisation, preferences (AUTHORITATIVE)

| Field | Value |
|---|---|
| Full name (as on CV) | `<FIRST> <LAST>` |
| Preferred name / pronoun | `<PREFERRED>` / `<PRONOUN>` |
| Email | `you@example.com` |
| Phone (international) | `+10000000000` |
| Phone (form without country code) | `0000000000` |
| City, State, Postal | `<CITY>, <STATE>, <POSTCODE>` |
| Country of residence | `<COUNTRY>` |
| Nationality | `<NATIONALITY>` |
| Work authorisation | `<e.g. requires sponsorship everywhere except X>` |
| Authorised without sponsorship | `<COUNTRY / none>` |
| Relocation | `<open to / restricted to>` |
| LinkedIn | `linkedin.com/in/<handle>` |
| GitHub | `github.com/<handle>` |
| Portfolio | `<url or none>` |
| Highest education | `<DEGREE, INSTITUTION, YEAR>` |
| Certifications | `<list — only tick what you actually hold>` |
| Driver's licence | `<Yes/No>` |
| Notice period | `<days>` |
| Earliest start | `<when>` |
| Travel willingness | `<%>` |
| Shift / on-call work | `<Yes/No>` |
| References available | `<Yes/No>` |
| Background check consent | `<Yes/No>` |
| Drug screening consent | `<Yes/No>` |
| Security clearance held | `<Yes/No>` |
| Reason for leaving | `<short neutral phrase>` |
| Languages | `<Language — level>` |

**Compensation**

| Field | Value |
|---|---|
| Expected (per month) | `USD <EXPECTED_MONTHLY_USD>` |
| Apply floor (per month) | `USD <FLOOR_MONTHLY_USD>` |
| Current compensation | `<currency + amount>` |
| Accepts equity / bonus | `<Yes/No>` |
| Contract types accepted | `<permanent / fixed-term >= N months>` |
| Skip if | `hourly / day-rate / contract below N months` |

**Skills — tick Yes ONLY for these**

`<comma-separated list of tools/skills you can defend in an interview>`

**Skills — NEVER claim these**

`<comma-separated list — the "willing to learn" tools go in free text, never as a Yes>`

Free-text "willing to learn" line: `<one sentence>`

**Eligibility / compliance**

| Question | Answer |
|---|---|
| Previously employed by this company | `<Yes/No>` |
| Criminal record | `<Yes/No>` |
| Referral by an employee | `<Yes/No>` |
| Need accommodation for a disability | `<Yes/No>` |
| Comfortable with AI-assisted screening | `<Yes/No>` |
| E-signature full name to type | `<FULL NAME>` |

---

## §1 — Hard walls (skip + log, never argue)

- Posting requires a skill on the never-claim list as a **core requirement**
- Citizenship-only / "no sponsorship" / existing-right-to-work required
- Posted band clearly below the apply floor
- Hourly / day-rate, or contract shorter than the minimum you accept
- Out-of-scope title (see each channel's scope block)
- Captcha / checkpoint wall, or a form bug after 3 attempts and 1 reload
- ATS requires account creation + email OTP with no SSO fallback

---

## §2 — Numeric screeners (answer exactly as written here)

Filling these ad-hoc is how a run produces inconsistent applications that get filtered out.

| Screener | Answer |
|---|---|
| Total professional years | `<n>` |
| Years in `<domain>` | `<n>` |
| Years with `<tool>` | `<n>` |
| Years managing people | `<n>` |
| Team size managed | `<n>` |
| On-call experience | `<n>` |
| Leading people | `<Yes/No>` |
| Agile experience | `<n>` |

**Salary conversion table** (fill with your own current rates — the automation converts the
annual figure into the posting's currency and never undercuts the floor):

| Currency | Annual equivalent of expected |
|---|---|
| USD | `<amount>` |
| EUR | `<amount>` |
| GBP | `<amount>` |
| SGD | `<amount>` |
| CAD | `<amount>` |
| AUD | `<amount>` |
| AED | `<amount>` |
| INR | `<amount>` |
| MYR | `<amount>` |

**Per-country apply floors** (a posting below its country's floor is skipped):

| Country | Floor per month |
|---|---|
| `<country>` | `<amount>` |

**Visa / sponsorship phrasing**

- "Authorized to work in `<country>`?" → `Yes` only for `<authorised countries>`; elsewhere
  `No + seeking sponsorship`, then submit anyway.
- "Will you now or in future require sponsorship?" → `<Yes/No>`
- Passport valid for travel → `<Yes/No>`

---

## §3 — Free-text templates

**"Tell us about yourself"** — `<3-4 sentences: years, domain, tools, one outcome>`

**"Why this role?"** — `<2-3 sentences, keep it generic; the run fills in the company name>`

**Cover letter** — skipped by default; attached only when the form requires one.

**"Anything else we should know?"** — left blank unless required.

---

## §4 — EEO / demographic

Decline to answer wherever the form allows it. Fill only fields marked required.

---

## §5 — Unanswered questions (the ask-don't-skip queue)

A required question with no answer in this bank is **not** a reason to abandon a job. The run
messages the configured Telegram chat with the exact question text and options, logs it here,
and continues with other jobs. If the answer arrives before the run ends, it comes back and
finishes that application.

| Date | Job | Question | Options | Status |
|---|---|---|---|---|
| `<date>` | `<title @ company>` | `<exact question>` | `<Yes/No/...>` | `<paused / answered>` |

Answer the question here in §0/§2/§3 as well, so the next run picks it up automatically.

---

## §6 — Run log

Append-only. This is also the **day-cap counter** for the channel (rows dated today with
`applied`), so never rewrite it.

```
date | title @ company, country | applied / skipped / needs-review | note
```

| Date | Job | Outcome | Note |
|---|---|---|---|
| `<date>` | `<title @ company, country>` | `<applied>` | `<confirmation text seen>` |

End every run with a `RUN SUMMARY` row: found / applied / skipped counts and the reason skips
happened.
