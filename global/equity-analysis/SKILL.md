---
name: equity-analysis
description: Full institutional equity-research initiation on a US SEC-filing company from one command. "/equity-analysis TICKER" fetches the filings from EDGAR, builds a cited, formula-driven Excel model (three statements, three parallel scenario DCFs with financing dilution, comps, precedents, sensitivities, cap table), recalculates and ties it out headless, draws 16-20 charts, writes a 40-50 page report and renders it to PDF, DOCX and TXT in the clean-pdf institutional-research look, verifies it and delivers it. Use when the user types /equity-analysis, or asks to "initiate coverage on X", "write an equity research report on X", "build a valuation model and initiation report for X", or "run the TNXP/SCTX process on X". "/equity-analysis setup" installs every dependency (Python packages, LaTeX, pandoc, LibreOffice); "/equity-analysis doctor" checks them; "/equity-analysis resume TICKER" continues an unfinished run from its HANDOFF.md.
argument-hint: "<TICKER> | setup | doctor | resume <TICKER>"
---

# /equity-analysis: initiation report, model and charts for one ticker

This is a long job (a full run is several hours of agent time and spawns research subagents). It produces:

| Output | What it is |
|---|---|
| `<Short>-<TICKER>-Initiation-<date>.pdf` / `.docx` / `.txt` | 40-50 page initiation: rating banner, thesis, Company 101, industry, financial analysis, projections, valuation, scenarios, risks, catalysts, appendices |
| `<Short>-<TICKER>-Model-<date>.xlsx` | Formula model: Assumptions, CapTable, Scenarios (Bull/Base/Bear engines), DCF, IS, BS, CF, Quarterly, Sensitivity, Comps, Precedents, Valuation, Sources, optional Pipeline rNPV. Every historical cell carries its filing citation as a comment |
| `charts/` | 16-19 standard charts plus company-specific ones, titles that state the finding |
| Project folder | git repo with `sources/` (filings, XBRL, market data), `hist.json`, `model_config.json`, `report_parts/`, `docs/decisions/`, `HANDOFF.md` |

## Arguments

- `TICKER`: run the whole pipeline below.
- `setup`: run Phase 0 setup only. `doctor`: run `eqa.py doctor --latex-test` and report.
- `resume TICKER`: open `<projects_dir>/<ticker>/HANDOFF.md`, run `eqa.py status`, and continue from the first unchecked phase.

## How to run the pipeline

`SKILL_DIR` is the base directory shown when this skill loads. Run every stage with the skill's venv Python:

- Windows: `PY = %USERPROFILE%\.equity-analysis\venv\Scripts\python.exe`
- macOS/Linux: `PY = ~/.equity-analysis/venv/bin/python`
- If the venv does not exist yet, use `python` (Windows) or `python3`, then create the venv in Phase 0.

`EQA = "<PY>" -I "<SKILL_DIR>/scripts/eqa.py" --project "<project dir>"`. Each stage is independent and safe to re-run; `EQA status` shows what is missing or stale. On Windows, prefer the PowerShell tool for these commands; quote every path. Shell state does not persist between calls, so write the full command each time.

## Non-negotiables

1. **Company facts come only from SEC filings, each with its accession.** Never use remembered numbers. If the company has no SEC filings (`eqa.py new` fails), **stop and tell the user** what you found. Do not substitute press coverage.
2. **Market data (prices, peers, consensus, precedents) is date-stamped** in `sources/peers.json`, with its source.
3. **Model numbers reach the report only through tokens** (`{{pt|usd2}}`, `{{table:comps}}`). Never retype a model number. Filing facts in prose carry an inline source ("10-Q Q2 2026").
4. **The model is done only when `EQA recalc` prints ALL CHECKS PASS with 0 error cells.** `verify-cites` must show 0 FAILED. Read the warnings.
5. **The report is done only when you have looked at every page** (`EQA sheets`, then Read each sheet image), `EQA check` is clean, and no `REPLACE` is left. Never report done from exit codes.
6. **Assumptions are researched, not defaulted.** `draft-config` writes placeholders marked DRAFT. Replace every driver with a number you can defend, and record why in `docs/decisions/`.
7. **Commit at each phase** (the project is a git repo). If a commit hook reports the push outcome, report it truthfully. No remote means local only.

## Phase 0: preflight and setup

1. Run `EQA doctor` (no `--project` needed). If it prints READY, continue.
2. If anything FAILs:
   - Software installs change the machine, so tell the user what will be installed and get a yes first.
   - Then run the installer for the platform. It creates the venv, installs Python packages, LaTeX, pandoc and LibreOffice, and runs `doctor --latex-test`. The first LaTeX run downloads packages and can take 5-10 minutes.
     - Windows: `powershell -ExecutionPolicy Bypass -File "<SKILL_DIR>/setup/install_windows.ps1"`
     - macOS: `bash "<SKILL_DIR>/setup/install_macos.sh"` (needs Homebrew; tlmgr asks for the admin password)
     - Linux: `bash "<SKILL_DIR>/setup/install_linux.sh"`
3. **SEC contact.** SEC requires a contact User-Agent. If doctor says it is unset, ask the user once for a name and email, then run `EQA setup --sec-user-agent "Name email@domain"`. Optional settings:
   - `--output-dir` (default `~/Documents/research`);
   - `--projects-dir` (default `~/equity-research`);
   - `--firm-name` and `--disclaimer` (both shown on the report).

## Phase 1: scope, filings and history

1. `EQA new TICKER` creates the coverage folder (git-initialised), the filing catalogue and the templates. Use `--date YYYY-MM-DD` to pin the report date. If the ticker is not found, stop (rule 1).
2. `EQA fetch --latest` downloads the following, each to `sources/<acc>/` as `.htm`, `.txt` and `.tables.txt`:
   - the latest two annual reports;
   - the 10-Qs since, plus three before;
   - recent 8-Ks, the proxy and any S-1/424B.

   Fetch anything else by accession (`EQA filings` lists the catalogue).
3. `EQA hist` drafts `hist.json` from XBRL, then `EQA locate` pins each value to a statement-table row and `EQA verify-cites` checks every citation. Read `references/hist-schema.md`, then:
   - **Fix each FLAG and MISSING cell from the statement tables** (`grep` the `.tables.txt`). XBRL mis-tags happen, which is why FLAGs exist.
   - **Add segment lines.** Use `seg:<name>` keys from the revenue-disaggregation note, each with its cite, and list them in `hist.segments`. Segment values must sum to revenue.
   - **Fill `shares.instruments`** from the equity note: options (with weighted-average exercise price), RSUs/PSUs (strike 0), warrants, pre-funded warrants, and convertibles if they are in the money. Fill `nol` from the income-tax note.
   - Re-run `verify-cites` until FAILED is 0.
4. Write a sourced business extract. Delegate it with the Agent tool: `subagent_type: general-purpose`, `model: sonnet`, using the brief in `references/research-briefs.md` (A), with the paths filled in. It writes `sources/extract_business.md`, a cited fact base with explicit FLAGs. Read it when it returns. Check every FLAG and spot-check at least three facts against the filing text yourself.
5. Commit: `phase 1: filings, cited history, business extract`.

## Phase 2: market, peers, precedents

1. Delegate peer and precedent research with brief (B) in `references/research-briefs.md` (`model: sonnet`; web search is allowed). It writes `sources/peers.json` (schema in that brief) and `sources/peers.md`, which cover:
   - 6-10 peers, each with the reason it was chosen and any exclusion with its reason;
   - NTM consensus revenue/EBITDA where a dated source exists;
   - precedent deals with their sources;
   - optionally, the subject's sell-side target range and analyst count.
2. `EQA market` fills prices, the 52-week range, the 10-year Treasury and each peer's fundamentals (EDGAR XBRL LTM). Check the subject's price against a second source, and record any discrepancy.
3. Commit.

## Phase 3: assumptions

1. `EQA draft-config` writes `model_config.json` with mechanical placeholders. Read `references/model-config.md` and `references/methodology.md`, then replace every driver. For each scenario, set:
   - segment revenue paths (growth or explicit values);
   - gross margin;
   - opex lines (percentage of revenue or absolute);
   - terminal margin;
   - issue price;
   - probability.

   Set these common inputs as well:
   - beta (with its source);
   - premiums;
   - terminal method;
   - D&A, capex and working-capital ratios (anchored to history);
   - minimum cash;
   - NOL;
   - debt and buyback schedules;
   - comps metric and weights.
2. Anchor every driver to evidence, such as guidance, history, peer data, the company's own disclosures or consensus. With a stub period, FY1 must exceed year-to-date actuals (recalc warns if not).
3. Add `pipeline` programmes (rNPV) for drug developers or other option-like assets.
4. Fill in `docs/decisions/<date>-valuation-and-rating.md` as you decide. Delete `"_status"` from the config when it is no longer a draft.

## Phase 4: model

1. Run `EQA build`, then `EQA recalc`. Repeat until ALL CHECKS PASS with 0 error cells. Some of the checks are arithmetic ties that pass by construction, including the historical ones, where residual lines absorb gaps. The ones that can actually fail are the independent recompute of V' and the engine-FCF-versus-statements reconciliation. The evidence that the history is right is `verify-cites` plus a clean set of history warnings. The checks cover:
   - balance sheet balance;
   - totals versus reported figures;
   - net income and EBIT versus reported figures;
   - the cash tie;
   - quarters versus annuals;
   - IS EBIT versus the DCF engine;
   - the scenario engine versus the DCF;
   - the sensitivity centres;
   - weights and probabilities.
2. Read every WARN, for example terminal value above 85% of EV, WACC near terminal growth, negative remainder-of-year revenue, or unordered scenarios. Fix the driver or justify it in the decisions file.
3. Read `out/keys.txt`, a values dump of every sheet, and sanity-check:
   - against management guidance and consensus;
   - that margins and returns are plausible for the sector;
   - that the share count path is sensible.
4. Iterate on Phase 3 until the model says something you believe. Commit.

## Phase 5: tables and charts

1. Run `EQA tables`, which writes `out/tables/*.md`, then `EQA charts`, which draws the standard set.
2. Write 6-15 company-specific charts in `<project>/charts_custom.py`. Typical subjects are product or segment KPIs, launch curves, unit economics, customer or payer coverage, market share, the pipeline timeline and the cap table or ownership.
   - The file receives `M` (model accessor), `finish`, the palette constants and `money`.
   - Read `references/report-guide.md` § Charts for the rules (and the dataviz skill if available).
3. Look at every chart: tile them (or Read each PNG). Fix overlapping labels, wrong signs and any title that does not match the data. Commit.

## Phase 6: report

1. Write `report_parts/01-03` following `references/report-guide.md`, at about 14-16K words in total.
   - Replace every `REPLACE`.
   - Put model numbers in only through tokens or generated tables (`{{table:name}}`).
   - Use captions that state findings, and cite filing facts inline.
   - Use the callouts (`keyinsight`, `thesisbox`, `riskbox`) sparingly.
   - Set the rating in the banner (the model's band plus your qualifier).
   - Delete template sections that do not apply (for example the issue-price sensitivity when no raise is needed, or precedents when there are none).
   - Prose: if the humanizer skill is available, run the report through it, keeping every number and citation.
2. Run `EQA widths`, `EQA render`, `EQA check` and `EQA sheets`. Read every sheet image and check each of these:
   - leaked table headers above headings;
   - orphaned headings;
   - overflowing tables;
   - missing glyphs;
   - wrong figure placement;
   - placeholders.
3. Fix, re-render and look again. Commit.

## Phase 7: verification (all of it, with evidence)

Follow `references/verification.md`. At minimum:
- `EQA recalc` shows ALL CHECKS PASS, and `EQA verify-cites` shows 0 FAILED.
- Five or more spot-checks: pick key figures in the report, such as latest-quarter revenue, the cash balance, the annual net loss/income, the share count and a guidance figure. Find each one in the filing text (`grep` `sources/<acc>/*.txt`) and record the accession and line in HANDOFF.md.
- PDF page count (from `check`), no `REPLACE`, every page viewed.
- If the `verify` skill is available, run it. If the DESIGN-TELLS file or the clean-pdf skill exists on this machine, check the PDF against it and say which tells you checked.
- Optional but recommended for a first report on a company: an independent review by a fresh agent (`model: opus`). Give it the PDF text and the model's `keys.txt`, not your conclusions, and ask it to find errors, unsupported claims and internal inconsistencies. Fix what it finds that holds up.

## Phase 8: delivery and follow-up

1. Run `EQA deliver`, which copies the PDF, DOCX, TXT and the recalculated model to the output folder. If a `SendUserFile` tool is available, send the PDF and model with a one-line caption: rating, price target versus price.
2. Update `HANDOFF.md` (status boxes, spot-checks, unverified claims) and commit.
3. **Follow-up.** The natural update is after the next 10-Q (or 10-K).
   - If `~/.claude/scripts/commitments.mjs` exists, record it with `node ~/.claude/scripts/commitments.mjs add`, including what to refresh and the expected filing date.
   - Otherwise, write it in HANDOFF.md under Next, and tell the user.
   - If the equity-research plugin's `earnings-analysis` / `model-update` skills are installed, name them for that update.
4. **Final message**, kept short:
   - the rating and price target versus price, with the implied return;
   - the three scenario values and the probability-weighted value, plus the comps value;
   - the two or three thesis points;
   - verification evidence: checks, spot-checks, pages, words, tables and charts;
   - file paths;
   - anything unverified or derived;
   - the follow-up.

## Skills this chains (use each if it is installed; the pipeline works without them)

| Skill | Where it applies |
|---|---|
| `clean-pdf` | the report look (header.tex here is its institutional-research variant) |
| `xlsx` | model conventions (colour code, no hard-codes in formulas, recalc) |
| `dataviz` | chart form, colour and labelling rules |
| `verify` | Phase 7 evidence discipline |
| `session-decisions` | the docs/decisions record |
| `humanizer` | the prose pass in Phase 6 |
| equity-research plugin `initiating-coverage` | its `assets/quality-checklist.md` as an extra Phase 7 checklist |
| equity-research plugin `earnings-analysis`, `model-update` | the follow-up update |

## Adapting to the company

Read `references/methodology.md` § Sector notes before Phase 3. In short:
- **Pre-revenue or launch-stage biotech:** model each asset once, either as a revenue segment or as a pipeline rNPV programme, never both, and keep pipeline Phase 3 costs out of the `rd` driver. Financing dilution usually dominates the value.
- **Banks, insurers, REITs:** not supported for the price target, because the engine is FCFF and the comps are EV-based. Tell the user before starting. If they proceed, value the company outside the Valuation sheet (P/TBV vs ROTCE, a dividend discount model, or P/FFO and NAV) and say so plainly in the report.
- **20-F / 40-F / 6-K filers and ADSs:** IFRS concepts are mapped, but check them harder. Their statements usually sit in exhibits: `fetch` pulls them and cites take the form `<acc> <file> T<n>.<r>`. A 40-F filer with no XBRL gets no draft hist; build it from the located exhibit tables. Keep the model in the reporting currency and set `reporting_currency`, `fx_rate`, `fx_date` and `listing_ratio` (ordinary shares per ADS) so per-share values convert to the listed security. Share counts and strikes stay per ordinary share.
- **Events after the balance-sheet date** (raises, buybacks, debt changes, a signed acquisition): enter them as `post_bs` and `pending_deal` (see model-config.md), never as negative claims. Otherwise the financing engine raises cash the company already has.
- **Preferred stock, special tax regimes (280E), changing capital intensity:** use `preferred`, per-scenario or per-year `tax_rate`, and per-year or per-scenario ratios (model-config.md).
- **Hand corrections survive re-runs:** `hist` and `market` merge by default and keep values marked manual; `--force` regenerates. Peers with missing fundamentals come out blank and excluded from medians, never as zero; a debt-free peer needs `debt_m: 0` set by hand.
- **De-SPACs:** if `hist` warns that the XBRL is the SPAC shell, draft the history from the located tables.
- **Recent IPOs with only an S-1:** build `hist.json` by hand from the S-1 tables.
- **Non-calendar fiscal years:** labels use the calendar year the fiscal year ends in.
