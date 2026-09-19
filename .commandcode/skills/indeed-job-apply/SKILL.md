---
name: "indeed-job-apply"
description: "Apply to Indeed DevOps/cloud jobs for the candidate against the candidate's real logged-in Brave. Use when running or repairing the Indeed auto-apply channel."
---

# Indeed Auto-Apply via Brave (candidate policy)

Apply to Indeed DevOps/cloud jobs for **the candidate** using the agent-browser CLI (`agent-browser connect 9222`) against the candidate's real Brave. Use whenever the candidate asks to find/apply
to jobs on Indeed, or when the scheduled run fires. Companion to the LinkedIn auto-apply skill.

**Full operating rules: `indeed-automation/RULESET.md`**
**Answer bank + run log: `indeed-automation/answers.md`**
Read both before running.

## Standing decisions (inherited from LinkedIn, the candidate)

- Full auto-submit; no per-job approval.
- DevOps/cloud roles ONLY; senior/lead titles preferred; worldwide markets (default ca.indeed.com).
- Nationality: <YOUR NATIONALITY>. Needs sponsorship everywhere except
  the authorised countries. Answer visa questions truthfully and SUBMIT — don't self-skip unless posting requires existing
  right-to-work or states no sponsorship.
- Salary floor USD <EXPECTED_MONTHLY_USD>/mo; per-country conversions in answers.md §3.
- Daily cap 30 (all platforms share the day); per-run ≤10.

## Verified mechanics (recon 2026-09-07)

- **"Apply with Indeed" opens a NEW smartapply.indeed.com tab** (not an iframe). Find it via
  `browser action=tabs` (URL starts `https://smartapply.indeed.com/beta/indeedapply/`) and act on it.
- Wizard with % progress: resume-selection (38%) → questions/1 contact (50%) → questions/N screener +
  attestation (50%) → review-module (100%) → submit.
- Resume already on Indeed (CV.pdf) — select its radio, Continue.
- Phone prefilled `10000000000` but country combobox resets to "Select an option" each application →
  click combobox, type `<YOUR COUNTRY>` in its search input (native value setter + input/change events), click
  the `[role=option]` "<YOUR COUNTRY> (+<COUNTRY CODE>)", then rewrite the phone input to `0000000000` (strip the 60).
- Screener questions: one `fieldset` per question; map `legend` text → answers.md §2 keyword table;
  click matching radio. Salary question = Annually radio + amount input (annual conversion) + currency
  combobox (search country dollar name, click option).
- **demographic-questions-module** (voluntary EEO ~88%, button says "Review your application" not
  Continue): gender/disability radios → "prefer not to answer"; ethnicity = multi-select dropdown
  (click combobox → click its `li` "prefer not to answer"); privacy-notice "Agree" checkbox often
  REQUIRED → check; then Review.
- Flow variants confirmed (2026-09-07): contact-info-module (name/email/phone prefilled) +
  profile-location (postal 00000 / City) can appear BEFORE resume-selection; demographics
  can appear after the screener. Handle whichever URL module is next until review-module.
- Attestation page: click the e-sign **checkbox input itself** (center of the input box, not the label),
  type full name `<YOUR FULL NAME>` into the name text input, answer AI-consent radio Yes.
- Review can hang on "Preparing review" when the invisible recaptcha.net anchor ERR_ABORTs (Brave).
  Reload the tab once (accept the beforeunload dialog via `browser action=dialog accept=true`) — the
  app returns to resume-selection with answers retained; re-walk fast and retry review.
- **Shields fix VERIFIED 2026-09-07:** Brave Preferences + Secure Preferences carry per-site
  shields-down (setting 1) exceptions for smartapply.indeed.com / indeed.com / recaptcha.net /
  gstatic.com — invisible reCAPTCHA now initializes and Submit enables (real submit to Medfar done).
  If submits fail again, re-apply the exceptions (backup: /tmp/Preferences.bak-indeed).
- Synthetic el.click() is sometimes ignored → scrollIntoView({block:'center'}) then real CDP click at
  element-center coords (`act` kind `clickCoords`). Verify state (checked/value) after each action.
- Buttons move/re-render → always re-read fresh center coords right before clicking; never click
  below the viewport (y > innerHeight).
- Compact `act evaluate` JSON probes beat full snapshots (snapshots churn the page).

## Flow

1. `browser action=status profile=brave` (cdpReady+pageReady) and `action=tabs`. Find an indeed.com
   tab; if none, `open` `https://ca.indeed.com/`. Confirm logged in (body contains "Welcome, ALAGARATNAM"
   or profile control). Not logged in → report "needs login", stop.
2. `open` a fresh labeled tab: `https://ca.indeed.com/jobs?q=<kw>&l=&from=searchOnHP&sort=date`
   (kw URL-encoded; rotate per ruleset §3).
3. Parse the result cards (compact evaluate), filter by title/scope/right-to-work per ruleset, click a
   card's title to open the detail pane.
4. Click "Apply with Indeed" → find the new smartapply tab.
5. Walk resume → contact → screener(s) → attestation → review → submit per ruleset §4, mapping answers
   from answers.md. Skip+log anything unmappable (ruleset §2).
6. On confirmation, close the smartapply tab, log the application in answers.md §6 (date | title @
   company, country | applied | submitted-OK), continue to next candidate (run cap 10, day cap 30).
7. End with a RUN SUMMARY row + concise report (WhatsApp/Telegram, <180 words): found/applied/skipped,
   why skips, blockers, manual steps needed.

## Gotchas

- Never `navigate` an attached tab (wedges debugger). Only `open` brand-new tabs with URLs.
- beforeunload dialogs are common when closing dirty apply forms — accept them.
- Full-page snapshots on smartapply can stall the page — use targeted evaluate probes.
- reCAPTCHA anchor aborts are intermittent; one reload usually fixes the review hang.
