# Company Targets — visa-sponsoring foreign employers (v1, 2026-09-07)

Seed list for the foreign direct-apply automation. **Priority: Canada and Singapore**, then rotation pool. Each run takes 5–8 companies from the scheduled country's block (prefer ones not visited in the last 7 days per ATS_REGISTRY.md) + any fresh company links found via Indeed/LinkedIn searches in that country.

Rules of use:
- ATS family column is a **guess to verify on first visit** — then record the verified family/URL in ATS_REGISTRY.md (append-only).
- If a careers URL 404s or redirects, search `<company> careers site` and record the corrected URL in the registry.
- "Sponsor posture" is indicative, not a guarantee — ALWAYS read the posting; the RULESET §2.2 exclusion language decides (boilerplate "eligible to work" ≠ exclusion; "citizens/PR only / no sponsorship / no LMIA / not open to overseas / SC clearance / SG-citizens-PR-only" = hard skip).
- Big banks/enterprise (Workday/SuccessFactors/Taleo, OTP account walls) are LOW priority: only attempt when the run has budget to spare AND Google SSO is offered.

---

## CANADA — priority 1 (LMIA / Global Talent Stream)

| Company | Careers URL | Hub(s) | ATS (guess) | Sponsor posture / notes |
|---|---|---|---|---|
| Shopify | https://www.shopify.com/careers | Ottawa/Toronto/Montreal/remote | verify | Sponsors via GTS; hires DevOps/Platform/Cloud |
| Amazon (incl. AWS) | https://www.amazon.jobs | Vancouver/Toronto | own ATS | Sponsors LMIA; huge DevOps infra hiring |
| Microsoft | https://careers.microsoft.com | Vancouver/Toronto/Montreal | own | Sponsors; guest + MS/Google login |
| Google | https://careers.google.com | Waterloo/Toronto/Montreal | own | Sponsors |
| Cohere | https://cohere.com/careers | Toronto | verify | AI scaleup; infra/platform roles — scope filter applies |
| Wealthsimple | https://www.wealthsimple.com/en-ca/careers | Toronto | verify | Fintech; sponsors; DevOps/SRE |
| 1Password | https://1password.com/careers | Toronto (remote CA) | verify | Sponsors; platform/security infra |
| Lightspeed | https://www.lightspeedhq.com/careers | Montreal | verify | Sponsors; SRE/DevOps |
| Hopper | https://www.hopper.com/careers | Montreal | verify | Sponsors; SRE/Data infra |
| Wave | https://www.waveapps.com/careers | Toronto | verify | Fintech |
| FreshBooks | https://www.freshbooks.com/careers | Toronto | verify | SaaS; DevOps |
| SOTI | https://www.soti.net/careers/ | Mississauga | verify | Sponsors; device mgmt |
| OpenText | https://jobs.opentext.com | Waterloo | verify (Workday-like?) | Enterprise; DevOps possible |
| D2L | https://www.d2l.com/careers/ | Kitchener-Waterloo | verify | EdTech |
| ecobee | https://www.ecobee.com/en-ca/careers/ | Toronto | verify | IoT |
| PointClickCare | https://www.pointclickcare.com/careers/ | Mississauga | verify | HealthTech; big DevOps org |
| ApplyBoard | https://www.applyboard.com/company/careers | Kitchener | verify | Sponsors; scaleup |
| Auvik | https://www.auvik.com/careers/ | Waterloo | verify | SaaS; DevOps/Platform |
| Klue | https://www.klue.com/careers | Vancouver | verify | SaaS |
| Visier | https://www.visier.com/company/careers/ | Vancouver | verify | People-analytics; SRE |
| Hootsuite | https://hootsuite.com/careers | Vancouver | verify | SaaS |
| Trulioo | https://www.trulioo.com/company/careers | Vancouver | verify | Identity; DevOps |
| Thinkific | https://www.thinkific.com/careers/ | Vancouver | verify | EdTech SaaS |
| Absolute Software | https://www.absolute.com/company/careers | Vancouver | verify | Cybersecurity (infra roles ok if DevOps/cloud) |
| BlackBerry (QNX/IVY) | https://www.blackberry.com/us/en/company/careers | Ottawa/Waterloo | verify | Infra/automotive — scope filter |
| Ericsson | https://www.ericsson.com/en/careers | Montreal/Ottawa | verify | Sponsors (GTS); big CI/CD/cloud ops |
| Nokia | https://www.nokia.com/careers | Ottawa | verify | Sponsors |
| CGI | https://www.cgi.com/en/careers | Montreal/Toronto | verify | Consulting; sponsors; many DevOps roles |
| Telus Digital | https://www.telusdigital.com/careers | Vancouver/Toronto | verify | Sponsors; product+agency |
| SAP Canada | https://www.sap.com/careers.html | Vancouver/Toronto/Montreal | verify | Sponsors |
| Electronic Arts | https://www.ea.com/careers | Vancouver | verify | Sponsors; game-infra DevOps |
| RBC / TD / Scotiabank / BMO / CIBC | bank careers sites | Toronto | Workday-family (LOW priority) | Rare sponsorship; only w/ Google SSO |
| Canada GTS public employer list | https://www.canada.ca/en/employment-social-development/services/foreign-workers/global-talent/employers-list.html | — | — | Optional cross-ref when CA pool is stale |

---

## SINGAPORE — priority 2 (Employment Pass / COMPASS)

| Company | Careers URL | ATS (guess) | Sponsor posture / notes |
|---|---|---|---|
| Grab | https://grab.careers | verify (Workday?) | Big EP sponsor; SRE/DevOps/Platform |
| Sea / Shopee | https://careers.shopee.sg | verify | EP sponsor; massive infra hiring |
| Lazada | https://www.lazada.com/careers | verify | Alibaba; EP |
| TikTok / ByteDance | https://careers.tiktok.com | own | EP sponsor; infra/SRE/DevOps roles |
| Google SG | https://careers.google.com | own | EP |
| Meta SG | https://www.meta.com/careers | own | EP |
| Amazon / AWS SG | https://www.amazon.jobs | own | EP |
| Microsoft SG | https://careers.microsoft.com | own | EP |
| Stripe | https://stripe.com/jobs | verify | EP; infra |
| Cloudflare | https://www.cloudflare.com/careers/ | verify | EP; SRE/DevOps |
| Datadog | https://www.datadoghq.com/careers/ | verify | EP; cloud infra roles |
| ServiceNow | https://www.servicenow.com/careers.html | verify | EP |
| Salesforce | https://www.salesforce.com/company/careers/ | verify | EP |
| PayPal | https://www.paypal.com/careers | verify | EP |
| Wise | https://www.wise.jobs | verify | EP; infra/DevOps |
| Revolut | https://www.revolut.com/careers/ | own | EP; platform/SRE |
| Airwallex | https://www.airwallex.com/careers | verify | EP; fintech infra |
| Xendit | https://www.xendit.co/careers/ | verify | EP; payments infra |
| Carousell Group | https://www.carousellgroup.com/careers (fallback search) | verify | EP |
| ShopBack | https://www.shopback.com/careers (fallback search) | verify | EP |
| Ninja Van | https://www.ninjavan.co/en-sg/careers | verify | EP |
| PropertyGuru | https://www.propertyguru.com/careers | verify | EP |
| 99.co | https://www.99.co/careers | verify | EP |
| Dyson (SG tech hub) | https://www.dyson.com/careers | verify | EP; big SW/hardware infra |
| Agoda | https://www.agoda.com/careers (SG office) | verify | EP |
| Klook | https://www.klook.com/careers (fallback search) | verify | EP |
| GovTech | https://www.govtech.gov.sg/careers | verify | Some EP roles but many citizens/PR-only — posting decides |
| NCS (Singtel) | https://www.ncs.co/careers/ | verify | EP; many cloud/DevOps roles |
| Singtel | https://www.singtel.com/about-us/careers | verify | EP |
| ST Engineering | https://www.stengg.com/en/careers | verify | EP |
| DBS / OCBC / UOB | bank careers sites | Workday/SF family (LOW) | EP possible for senior; only w/ Google SSO |
| GIC | https://www.gic.com.sg/careers/ | verify (Workday?) | EP for senior; low volume |
| Standard Chartered SG | https://jobs.sc.com | SuccessFactors family | EP; DevOps roles exist |
| JPMorgan Chase SG | https://careers.jpmorgan.com | own | EP; big SRE/DevOps org |
| Citi SG | https://jobs.citi.com | own | EP |

---

## ROTATION POOL (evening runs) — AU / UK / IE / DE / NL / UAE / remote-global

| Country | Company | Careers URL | Notes |
|---|---|---|---|
| AU | Atlassian | https://www.atlassian.com/company/careers | Sponsors (482/186); strong DevOps/Platform |
| AU | Canva | https://www.lifeatcanva.com/careers | Sponsors |
| AU | Xero | https://www.xero.com/au/about/careers/ | Sponsors |
| AU | Culture Amp | https://www.cultureamp.com/careers | Sponsors |
| AU | SafetyCulture | https://safetyculture.com/careers/ | Sponsors |
| AU | SEEK | https://www.seek.com/company/careers (fallback search) | Sponsors |
| AU | Block (Afterpay) | https://block.xyz/careers | Sponsors |
| AU | Envato | https://envato.com/careers/ | Sponsors |
| UK | Monzo | https://monzo.com/careers/ | Sponsors (Skilled Worker); SRE/Platform |
| UK | Wise | https://www.wise.jobs | Sponsors |
| UK | Revolut | https://www.revolut.com/careers/ | Sponsors |
| UK | Checkout.com | https://www.checkout.com/careers | Sponsors; infra |
| UK | Octopus Energy | https://octopus.energy/careers/ | Sponsors |
| UK | Starling Bank | https://www.starlingbank.com/careers/ | Sponsors; platform |
| UK | Deliveroo | https://deliveroo.co.uk/careers (fallback search) | Sponsors |
| UK | Trainline | https://www.trainlinegroup.com/careers/ | Sponsors |
| IE | Stripe Dublin | https://stripe.com/jobs | Sponsors; big infra hub |
| IE | Intercom | https://www.intercom.com/careers | Sponsors; Dublin infra |
| IE | Workday Dublin | https://www.workday.com/en-us/careers | Sponsors (large Dublin org) |
| IE | HubSpot | https://www.hubspot.com/careers | Sponsors |
| IE | MongoDB Dublin | https://www.mongodb.com/careers | Sponsors |
| IE | Squarespace | https://www.squarespace.com/careers | Sponsors |
| DE | Zalando | https://jobs.zalando.com | Sponsors; Berlin; English ok |
| DE | Delivery Hero | https://www.deliveryhero.com/careers/ | Sponsors; Berlin |
| DE | HelloFresh | https://careers.hellofresh.com | Sponsors; Berlin |
| DE | N26 | https://n26.com/en/careers | Sponsors; Berlin |
| DE | Celonis | https://www.celonis.com/careers/ | Sponsors; Munich |
| DE | Contentful | https://www.contentful.com/careers/ | Sponsors; Berlin |
| DE | Personio | https://www.personio.com/careers/ | Sponsors; Munich |
| NL | Adyen | https://www.adyen.com/careers | Sponsors (Highly Skilled Migrant); Amsterdam |
| NL | Booking.com | https://careers.booking.com | Sponsors; Amsterdam |
| NL | Mollie | https://www.mollie.com/careers | Sponsors; Amsterdam |
| NL | TomTom | https://www.tomtom.com/careers/ | Sponsors |
| NL | Picnic | https://picnic.app/careers/ | Sponsors; Amsterdam |
| NL | ASML | https://www.asml.com/en/careers | Sponsors; Veldhoven — some cloud/DevOps |
| UAE | Careem | https://www.careem.com/en-ae/careers/ | Dubai; sponsors (UAE work visa) |
| UAE | Talabat | https://www.talabat.com/careers (fallback search) | Dubai; sponsors |
| UAE | Kitopi | https://www.kitopi.com/careers/ | Dubai; sponsors |
| UAE | Property Finder | https://www.propertyfinder.ae/careers.html | Dubai; sponsors |
| UAE | Emirates Group | https://www.emiratesgroupcareers.com | Dubai; sponsors |
| UAE | Noon | https://www.noon.com/careers/ | Dubai; sponsors |
| Remote-global | GitLab | https://about.gitlab.com/jobs/ | Fully remote; hires globally (country list in posting) |
| Remote-global | Canonical | https://canonical.com/careers | Fully remote; hires globally |
| Remote-global | Elastic | https://www.elastic.co/careers | Remote-first; hires globally |
| Remote-global | Automattic | https://automattic.com/work-with-us/ | Fully remote |

---

## Search fallbacks (when seed pool is stale/exhausted for a country)
- Indeed country site per ATS_PLAYBOOK §5 (also surfaces "Apply on company site" companies not in the seed list).
- LinkedIn Easy Apply per RULESET §4.3.
- For CA/SG specifically: LinkedIn company pages of the seed list + "X careers" search results are acceptable discovery — but ALWAYS prefer the company's own ATS for submission.

## EUROPE — English-only block (added 2026-09-07 per the candidate: "Try UK, Finland, any other European, but I only know English")

English-language-only requirement applies to every role below — skip any posting that needs Finnish/German/French/Dutch/etc.

### FINLAND (Helsinki tech scene is English-friendly; EU Blue Card available)
| Company | Careers URL | ATS (guess) | Notes |
|---|---|---|---|
| Wolt | https://careers.wolt.com | Greenhouse | English working language; platform/infra roles |
| Supercell | https://www.supercell.com/en/careers | own | English; infra/SRE (games) — scope filter applies |
| Unity (Finnish sites) | https://careers.unity.com | own | English; DevOps/cloud |
| KONE | https://careers.kone.com | Workday | English; digital/cloud infra |
| Nokia (Espoo/Helsinki) | https://www.nokia.com/careers | own | English; cloud/5G infra DevOps |
| Smartly.io | https://www.smartly.io/careers | Greenhouse | English; DevOps/SRE |
| Zalando (if remote-EU) | https://jobs.zalando.com | own | English; platform |
| Iceye / Reaktor / Vincit | check | — | English-first Finnish firms; verify boards live |

### UK (existing) — English native; skip SC-clearance/5-yr-residency/settled-status
### IRELAND — English; CSEP visa path (HubSpot, Stripe, Intercom, Workday, ServiceNow, Microsoft, Google, Amazon — Dublin)
### NETHERLANDS — English-OK at scaleups (Adyen, Booking, Mollie, Databricks, Uber, Netflix) — high-skilled migrant visa
### GERMANY — English-only postings at Berlin tech (Zalando, Delivery Hero, HelloFresh, N26, Personio, Contentful) — Blue Card; skip German-required
