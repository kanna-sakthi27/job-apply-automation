# bank/core.md — CANONICAL ANSWER CORE (the only bank a run needs to read)

> **This is the one file you must edit.** Everything else in the repo is engine or per-site
> mechanics. Copy this template to `bank/core.md`, fill it in, and every channel answers from it.
>
> **Authority:** if any other file — a prompt, a ruleset, a skill — disagrees with this file,
> this file wins. That is stated in every prompt so a run cannot talk itself out of your policy.
>
> **Keep it small on purpose.** Runs read this file once at the start, so it is the single biggest
> lever on what a run costs. Do not paste append-only history here: run logs belong in each
> channel's own `answers.md` §6.
>
> **Two rules that keep the whole system honest:**
> 1. **Never invent a fact.** No answer here → the run asks (or skips), it does not guess. A
>    fabricated visa status or years-of-experience number on a real application is the one
>    failure you cannot undo.
> 2. **Odd-but-true beats plausible.** If your real answer is unusual (a numeric field you must
>    answer 0 on, a title your CV does not match), write it down here explicitly. Anything left
>    out becomes a guess.

---

## 1. Scope — what to apply to, and what to never apply to

Mark this section as binding. A run that widens scope to find more jobs is worse than a run that
applies to nothing.

**In scope:** `<role families, seniority level, e.g. "Senior/Lead DevOps, Cloud, Platform, SRE,
Infrastructure — engineer and technical-manager level">`

**Out of scope — never apply:** `<e.g. "pure software/backend/web, data, ML/AI, QA, non-DevSecOps
security, pure networking, DBA, frontend, junior/intern">`

**Ambiguous title:** `<the tie-breaker, e.g. "the core responsibility must be infrastructure
automation, else skip">`

---

## 2. Identity

| Field | Answer |
|---|---|
| Full legal name (as on CV) | `<NAME>` |
| Preferred name / pronoun | `<PREFERRED>` / `<PRONOUN>` |
| Email | `<EMAIl>` |
| Phone (international) | `<+10000000000>` |
| Phone (form without country code) | `<0000000000>` |
| City, State, Postal | `<CITY>, <STATE>, <POSTCODE>` |
| Country of residence | `<COUNTRY>` |
| Education | `<DEGREE — INSTITUTION, YEAR>` |
| LinkedIn | `linkedin.com/in/<handle>` |
| GitHub / portfolio | `github.com/<handle>` |
| CV to upload | `cv/CV.pdf` |
| Driver's licence | `<Yes/No>` |

---

## 3. Work authorization — usually the most-mistaken field

Write this out explicitly. Visa questions are where a guessed answer is unrecoverable.

- **Nationality:** `<...>` — `<any "never tick X" warning you need>`
- **Passports held:** `<...>` — "Do you have a valid passport?" → `<Yes/No>`
- **Current status:** `<e.g. "in <country> on an employer-tied permit">`
- **Sponsorship required for:** `<countries, or "every country except X">`
- **Authorized to work without sponsorship:** `<countries>`
- **Relocation:** `<worldwide / restricted>`
- Security clearance ever held: `<Yes/No>`

| Question shape | Answer |
|---|---|
| "Will you now or in the future require sponsorship?" | `<Yes/No>` |
| "Are you authorized/legally eligible to work in [country]?" | `<country> → Yes · elsewhere → <answer>` |
| "Do you hold a work visa for [country]?" | `<answer>` |
| "Do you require sponsorship?" | `<answer>` |
| "Willing to relocate to [city]?" | `<Yes/No>` |

---

## 4. Compensation

| Item | Value |
|---|---|
| **Expected (always state this)** | `<CURRENCY amount/month>` |
| **Apply-floor — skip postings below** | `<CURRENCY amount/month>` |
| Current | `<amount>` |
| Equity / bonus | `<Yes/No>` |
| Contracts accepted | `<permanent / fixed-term >= N months>` |
| Skip | `<hourly / day-rate / below N months>` |

**Expected converted** — fill in the currencies of the markets you actually search, so a run never
does live FX arithmetic:

| Currency | Monthly | Annual |
|---|---|---|
| `<CUR>` | `<amount>` | `<amount>` |

**Floor converted** (skip a posting whose advertised band is below these):
`<CUR amount · CUR amount · …>`

---

## 5. Experience — numeric screeners

A run that answers these ad-hoc produces inconsistent applications. Pin them.

Total professional `<n>` · `<domain>` `<n>` · `<tool>` `<n>` · managing people `<n>` ·
largest team led `<n>` · on-call `<n>` · `<other screeners>`

**Easy-to-get-wrong fields** — call these out explicitly, they are the ones runs botch:

- `<e.g. "Tool X — a NUMERIC years field is 0 (do not write 3"); a Yes/No 'do you have X
  experience?' is Yes (certified, production)">`

**Leadership / scale free-text:** `<one or two sentences with concrete numbers>`

---

## 6. Skills — claim / never claim

**Claim:** `<comma-separated tools you can defend in an interview>`

**Never claim:** `<comma-separated tools you cannot>` — for anything you are willing to learn, say
where it is allowed: `<e.g. "optional free-text only, never a Yes box">`

**A required core skill from the never-claim list → skip the job + log.**

**Other flags:** `<domain experience, certifications, yes/no questions you must answer a specific
way>`

---

## 7. Preferences & compliance

| Field | Answer |
|---|---|
| Notice period | `<n days>` |
| Earliest start | `<...>` |
| Travel | `<%>` |
| Shifts / on-call | `<Yes/No>` |
| Work style | `<remote-first / on-site>` |
| Reason for leaving | `<neutral phrase>` |
| Languages | `<Language (level)>` |
| Prior employee of [company] | `<Yes/No>` |
| Criminal record | `<Yes/No>` |
| Referral by an employee | `<Yes/No>` |
| Accommodation needed | `<Yes/No>` |
| Background check consent | `<Yes/No>` |
| Drug screening consent | `<Yes/No>` |
| References available | `<Yes/No>` |
| EEO / demographic | `<Decline — "do not wish to answer">` |
| AI-screening consent | `<Yes/No>` |
| E-signature name to type | `<FULL LEGAL NAME>` |

**Skip + log (do not ask):** `<the walls you never want a run to waste a turn on>`

---

## 8. Free text

**Short intro ("tell us about yourself"):**
> `<3-4 sentences: years, domain, tools, one concrete outcome>`

**"Why this role":**
> `<2-3 sentences, generic enough that the run can drop in the company name>`

**Cover letter:** skip by default, attach only when required:
> `<full letter, or delete this if you never want one>`

**"Anything else":** `<blank / the short intro>`

---

## 9. Budgets & escalation

**Caps:** `<n>` submitted applications per channel per day; per-run target `<n>`. Count only *this
channel's* log for this channel's cap.

**Unanswered required question:** never invent. Ask the operator on Telegram
(`tools/tg-notify.sh`) with the job and the exact question, log it, and continue with other jobs.
Skip only on a true wall.
