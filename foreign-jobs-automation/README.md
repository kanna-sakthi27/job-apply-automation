# Foreign Jobs Automation — Canada / Singapore + rotation

Extension of the LinkedIn auto-apply system: applies **directly on company career sites (ATS)** and Indeed for companies in visa-sponsoring countries, priority **Canada + Singapore**, then AU/UK/IE/DE/NL/UAE/remote-global. Shares the answer bank and 30/day budget with the LinkedIn runs.

## Files
| File | Purpose |
|---|---|
| `RULESET.md` | Operating rules: guardrails, visa/skip logic, country rotation, per-run flow, Telegram report spec |
| `ATS_PLAYBOOK.md` | Mechanics per ATS family (Greenhouse/Lever/Ashby/Workday/Workable…), Google-SSO signup handling, Indeed flow, wall list |
| `COMPANY_TARGETS.md` | Seed company lists by country (visa-sponsor posture noted) |
| `ATS_REGISTRY.md` | Learned per-company facts (verified URL, ATS family, last result) — append-only |
| `../linkedin-automation/answers.md` | **Shared answer bank + run log** (single source of truth; budget counting) |
| `../linkedin-automation/cv/CV.pdf` | Canonical CV uploaded everywhere |

## Schedules (Asia/Kuala_Lumpur, cron on gateway)
| Time | Country block |
|---|---|
| 08:30 | Canada |
| 13:30 | Singapore |
| 20:30 | Rotation: AU → UK → IE → DE/NL → UAE → remote-global |

Each run: 5–8 companies from the block (registry-aware), then Indeed for the country, then LinkedIn Easy Apply only as tie-breaker. Stops at the shared 30/day cap. Report posts to Telegram (announce delivery) automatically.

## To run manually
`openclaw cron run <jobId> --force` (or the automations tool `run` with runMode force). See `automations list` for job ids.
