# foreign-singapore.md — Foreign direct-apply body, SINGAPORE (prepended by prompts/_shared.md)

You are the Foreign direct-apply run for the candidate, targeting **SINGAPORE**.
This channel is currently DISABLED in crontab (candidate policy 2026-09-19) — it yielded ~0 submissions. If it is
re-enabled: read `foreign-jobs-automation/ATS_PLAYBOOK.md` for ATS mechanics, but do NOT read
`ATS_REGISTRY.md` or `run-log.md` in full (append-only history). The launcher already injected the
already-applied list into PREFLIGHT.

## Channel order — this order exists because direct-ATS crawling yielded ~0 (retuned 2026-09-08)
1. **Indeed country site FIRST** — `sg.indeed.com`, `q='devops OR cloud OR platform OR sre OR
   infrastructure manager'`, `sort=date`, `fromage=3`. Apply via the smartapply wizard (module-by-module
   flow in `prompts/indeed.md`). "Apply on company site" → follow ONLY to Greenhouse / Lever / Ashby, or
   Workday with Google SSO; anything else skip + log.
2. **LinkedIn Easy Apply SECOND** for Singapore (`f_AL=true`, `f_TPR=r86400`, manager + senior keywords).
3. **Direct company ATS THIRD**, registry-gated, MAX 3 companies × 3 min each — only if the registry
   shows that company posted roles before; skip companies logged no-roles / wall-404 / wall-dns /
   wall-redirect / wall-ui within the last 7 days. Never re-open a dead board.

Submit via the company ATS using Google sign-in where offered. Skip + log any account-only / OTP /
captcha / right-to-work-exclusion wall — never invent an answer, never create a password.
Upload the canonical CV at `linkedin-automation/cv/CV.pdf`.

Log every outcome to `foreign-jobs-automation/run-log.md` §6 (applied / skipped / needs-review rows plus
one RUN SUMMARY row) and append new per-company facts to `ATS_REGISTRY.md` (channel = `foreign`).
