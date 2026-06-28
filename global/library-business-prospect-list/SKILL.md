---
name: library-business-prospect-list
description: |
  Build a geographic B2B prospect / lead list of local businesses and their owner/decision-maker
  contacts for FREE, then geocode and distance-sort it into a clean spreadsheet + readable PDF.
  Use when asked to: "build a prospect/lead list of businesses near <place>", "find local business
  owners/partners to contact", "list companies in <area> with phone numbers / decision-makers",
  "make a spreadsheet of businesses sorted by distance", or any local-sales / cold-outreach
  territory list. Covers: the FREE Data Axle Reference Solutions access (via any public library
  card, remote), why "all C corps / all businesses in <state>" is the wrong ask, the Census batch
  geocoder + Haversine pipeline, owner/partner title filtering + institutional-NAICS exclusion, the
  hard-won Data Axle browser-automation gotchas (coordinate-clicks tag, ref-clicks don't; 250/search
  cap; hand tag+download to the human), and TCPA/CAN-SPAM compliance for regulated outreach.
author: Claude Code
version: 1.0.0
date: 2026-06-27
---

# Library Business Prospect List

## Problem
Someone wants a list of local businesses + decision-maker contacts to call/email (sales territory,
cold outreach, market research), and the naive asks ("all C corps in NY", "every business in NJ")
are both impossible and useless. Paid tools (ZoomInfo, Apollo, Data Axle direct) cost real money.
There is a FREE, legitimate path most people don't know about.

## Context / Trigger Conditions
- "Build me a prospect/lead list of businesses near <town/ZIP>."
- "Find local business owners/partners to approach about <product/service>."
- "Spreadsheet of companies in <area> with names, titles, phone numbers, sorted by distance."
- Insurance / financial / B2B-services sales territory building; door-knock / cold-call lists.

## Solution

### 1. Reset the impossible asks (do this first, out loud)
- **"C corp" is not a queryable field.** State business registries record entity *type*
  ("Domestic Business Corporation", "LLC"), NEVER the C-vs-S federal tax election (an IRS Form 2553
  matter, not public). The honest proxy is "active business corporations."
- **"All of <state>" is noise**, not a list: mostly shells, holding companies, no-employee
  registrations. The useful target is **likely employers** (or **owner-operated SMBs**) near a point.
- Some states (e.g. NJ) have **no free bulk business registry** at all (per-record paid). Don't rely
  on state registries for a contact list.

### 2. The free data source: Data Axle Reference Solutions via a public library card
- **Data Axle Reference Solutions** (formerly ReferenceUSA) is FREE and **remotely accessible with
  most US public library cards** (confirmed: LA Public Library, Monmouth County NJ; check the target
  library's "research databases" page). It's a NATIONAL DB, so you can pull any US geography from
  anywhere.
- One record gives: **company, full address, business phone, owner/officer (executive) name + title,
  employee count, NAICS/industry, website.** It does **NOT** carry email (enrich separately).
- Login: library's databases page → "Reference Solutions" / "Data Axle" → enter the library card
  number (+ PIN). The card holder logs in; you never need their credentials in plaintext.

### 3. Search recipe (Advanced Search)
- **Geography → Radius:** center ZIP + miles. (Or ZIP-Codes geography for specific towns.)
- **Business Size → Number of Employees:** for **owner-operated SMBs** pick **10-49** (President =
  owner at this size). The **100+ tier near most towns is mostly schools/government/institutions**
  (administrators, not owners) — avoid it for an owners/partners list.
- **Industry (NAICS), optional:** prioritize contractors (23), manufacturing (31-33), wholesale
  (42), retail (44-45), finance (52), professional svcs (54), health (62), food/lodging (72).
- **Record Type:** Verified Businesses.
- **Download:** Detailed (all fields), Comma Delimited. Cap is **250 records per search** (25/page).

### 4. Browser-automation reality — hand the tag+download to the human
Driving Data Axle's results page with claude-in-chrome is FRAGILE. The reliable split: **Claude
builds the search (form_input/find/navigate/read_page are reliable) and processes the CSV; the human
does the authenticated tag+download** (their real clicks work first try). Specifically:
- **Coordinate-clicks fire checkbox change handlers; ref-clicks DON'T** (the box looks unchecked and
  the download says "nothing selected"). Links/buttons/`<option>`s are fine via ref.
- **Screenshots freeze** intermittently on the heavy results page (CDP 30s timeout), so
  coordinate-tagging deadlocks. A **fresh tab** sometimes clears a stuck renderer (session cookie
  carries). `read_page`/`find`/`get_page_text` stay reliable.
- **Don't re-click "Select All"** on a page you've paged through — it's a toggle and untags.
- Hitting the **250/search cap** makes Download silently produce no file. Reset = New Search.

### 5. Process the downloaded CSVs (this part is fully automatable + reliable)
Pipeline (reference impl: `~/.claude/projects/marlboro-prospects/`):
1. **Geocode** each address: FREE **US Census batch geocoder**
   (`https://geocoding.geo.census.gov/geocoder/locations/addressbatch`, benchmark=Public_AR_Current,
   10k rows/request) → Nominatim fallback (1 req/s) → ZIP-centroid fallback (from the Census
   Gazetteer ZCTA file).
2. **Distance:** Haversine from the target center point; keep ≤ radius; **sort nearest-first**.
3. **Filter to decision-makers:** keep rows whose exec title is Owner/Partner/Principal/Founder/
   Managing Member (+ President/CEO at SMB size). Scan ALL exec columns (Data Axle Detailed has up
   to 50 execs/record) and pick the best owner-class title.
4. **Drop institutions** by NAICS prefix: schools `6111/6112/6113`, government `92`, hospitals `622`,
   religious `8131` (administrators, not owners). (Keep `6116` — dance/driving/sports schools are
   owner-run.)
5. **Dedupe** (company+street+city), then output.
6. **Header quirks:** phone col is "Phone Number Combined"; employee counts are zero-padded
   ("00020"); map fuzzily, not by exact header name.

### 6. Output
- **xlsx** (openpyxl): a Prospects sheet + a Compliance sheet for regulated outreach.
- **Readable PORTRAIT PDF** (fpdf2): one business per line — `# | dist | Company | Owner | Role |
  Phone | Address | Website`. Truncate-to-fit; alternating shading; repeating header. (A wide
  landscape spreadsheet-dump PDF is unreadable; portrait one-line-per-business is what people use.)
- **Compliance block** for regulated sellers (insurance, finance): cold-call **business landlines**
  only (not scraped cells); scrub federal + state Do-Not-Call every 31 days; CAN-SPAM (real address,
  honest subject, working opt-out) for email; and any captive-agent carrier (e.g. New York Life)
  generally must pre-approve prospecting lists + scripts. Informational, not legal advice.

## Verification
- Geocoder sanity: confirm a few known-distance towns land right (e.g. a town ~7 mi away reads ~7).
- Row counts at each stage (raw → owner/partner filter → institutions dropped → ≤radius → deduped).
- Spot-check 5 rows' owner name + phone against the company website.

## Example
"Build my dad a list of business owners near Marlboro NJ to sell insurance to" →
Data Axle (his library card) radius 07746 / 4 mi / 10-49 employees / Detailed CSV → pipeline →
**181 owner/partner prospects within ~7 mi, all with phone + address, nearest-first**, as xlsx +
portrait PDF with a compliance sheet.

## Notes
- **Email is NOT in Data Axle** — enrich separately via Hunter.io / Apollo free tiers (by company
  domain), flagged unverified. Website (in the data) is the stand-in digital contact.
- Many public libraries also offer **Mergent Intellect** (more executive contact detail) free.
- For a "broad" list past 250 records, do **town-centered radius pulls outward** and dedupe the
  combined set, rather than one giant search.
- Reference implementation with working scripts:
  `~/.claude/projects/marlboro-prospects/scripts/{build_target_zips,distance_sort,build_workbook,make_pdf}.py`.

## References
- US Census Geocoding Services API: https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html
- US Census ZCTA Gazetteer (ZIP centroids): https://www2.census.gov/geo/docs/maps-data/data/gazetteer/
- Data Axle Reference Solutions (find a library): https://www.data-axle.com/platforms-products/reference-solutions/
- See also memory: `project_marlboro_prospect_pipeline`, `feedback_dont_grind_browser_automation_heavy_authed_webapps`.
