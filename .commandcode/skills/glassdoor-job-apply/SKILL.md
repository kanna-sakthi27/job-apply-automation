---
name: "glassdoor-job-apply"
description: "Apply to Glassdoor DevOps/cloud jobs for the candidate against the candidate's real logged-in Brave. Use when running or repairing the Glassdoor auto-apply channel."
---

# Glassdoor Auto-Apply via Brave (candidate policy)

Apply to Glassdoor DevOps/cloud jobs for **the candidate** using the agent-browser CLI (`agent-browser connect 9222`) against the candidate's real Brave. Use whenever the candidate asks to find/apply
to jobs on Glassdoor, or when the scheduled run fires. Companion to the LinkedIn, Indeed, and
foreign-direct auto-apply skills.

**Full operating rules: `glassdoor-automation/RULESET.md`**
**Answer bank + run log: `glassdoor-automation/answers.md`**
**Common applied-jobs registry (cross-apply guard): `applied-jobs-registry.md`**
Read all before running.

## Standing decisions (inherited from LinkedIn/Indeed, the candidate)

- Full auto-submit; no per-job approval.
- DevOps/cloud roles ONLY (engineer + technical-manager: DevOps/Cloud/Infra/SRE/Platform Manager,
  Team Lead, Head, etc.); worldwide markets; Easy-Apply-only in v1.
- Nationality: <YOUR NATIONALITY>. Needs sponsorship outside the authorised countries.
  Answer visa questions truthfully and SUBMIT — don't self-skip unless posting requires existing
  right-to-work or states no sponsorship.
- Expected salary USD <EXPECTED_MONTHLY_USD>/mo; apply-floor USD <FLOOR_MONTHLY_USD>/mo; conversions in answers.md §3.
- Daily cap 30 per channel; per-run ≤10. Cross-apply guard: check the registry before each submit.

## Verified mechanics (recon 2026-09-07)

- **Glassdoor "Easy Apply" opens a NEW smartapply.indeed.com tab** (same parent company, Recruit
  Holdings): URL `https://smartapply.indeed.com/beta/indeedapply/form/...`; the Glassdoor job tab
  bounces back with `from=smart-apply&ea=1`. The wizard, resume, and answers are IDENTICAL to the
  Indeed flow — follow the Indeed skill's verified mechanics (resume-selection 38% → contact →
  profile-location → screener questions/N → attestation → demographics/EEO → review 100% → submit).
- Resume CV.pdf is preloaded + pre-selected (Indeed profile).
- Search: `https://www.glassdoor.com/Job/jobs.htm?sc.keyword=<kw>` — results redirect to a canonical
  `/Job/<country>-<kw>-jobs-SRCH_...htm` URL. Add `&filter.easyApply=true` to keep only Easy Apply
  jobs. Filter card list to `a[href*="/job-listing/"]`.
- Job detail page apply buttons: **"Easy Apply"** (proceed) vs **"Apply on employer site"** (external
  → skip+log in v1).
- Easy Apply does NOT require a Glassdoor account (powered by the Indeed session). the candidate has no
  Glassdoor login yet (2026-09-07) — fine for Easy Apply; a login is only needed for saved jobs/search
  alerts (optional).
- Shields: the Indeed recaptcha shields-down exceptions (smartapply.indeed.com / indeed.com /
  recaptcha.net / gstatic.com) already apply; add `glassdoor.com` if recaptcha issues appear on
  Glassdoor pages.

## Flow

1. `browser action=status profile=brave` (cdpReady+pageReady) and `action=tabs`. Find/`open` a
   glassdoor.com tab. Not needed: Glassdoor login (see above). Confirm the Indeed session is alive by
   checking the smartapply tab shows the candidate's resume once opened.
2. `open` a fresh labeled tab with the keyword search URL (+ `&filter.easyApply=true`).
3. Parse the result cards (compact evaluate), filter by title/scope/floor/right-to-work + the common
   registry (no cross-apply), click a card to open the detail pane.
4. Click **Easy Apply** → find the NEW smartapply.indeed.com tab → walk resume → contact →
   screener(s) → attestation → EEO → review → submit per RULESET §4, mapping answers from answers.md.
   Skip+log anything unmappable.
5. On confirmation: close the smartapply tab, log the application in answers.md §6 AND append to
   `applied-jobs-registry.md`; continue to next candidate (run cap 10, day cap 30).
6. End with a RUN SUMMARY row + concise report (Telegram, <180 words).

## Gotchas (inherited from Indeed — all apply)

- Never `navigate` an attached tab; only `open` new tabs. Use `location.reload()` via evaluate.
- Smartapply steps appear in VARIED order by employer — identify by URL module, not a fixed sequence.
- If Continue/Submit is disabled with the reCAPTCHA footer note → reload the smartapply tab once
  (accept beforeunload), re-walk; still disabled → skip + log.
- beforeunload dialogs common when closing dirty forms — accept them.
- Synthetic el.click() sometimes ignored → scrollIntoView + real CDP click at element-center coords.
- Buttons move/re-render → always re-read fresh center coords right before clicking.
- Full-page snapshots churn the page → use compact `act evaluate` JSON probes.
