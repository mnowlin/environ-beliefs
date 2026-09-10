# Session Log — environ-beliefs Project

Paper title: **"Environmental Belief System Networks and Pro-Environmental Behavior"**

This log records what has been done in each working session. Update it at the end of each session.

---

## Project Overview

An academic article examining how environmental beliefs are connected in
belief-system networks and which beliefs have the shortest paths to
self-reported pro-environmental behavior. Two studies:

- **Study 1** — US data collected July 2017 (*N* = 501), Survey Sampling Inc.,
  online. Beliefs: political ideology, environmentalist identity, CNS, NEP,
  and cultural-cognition batteries. Behavior: 13-item pro-environmental
  behavior scale (2000 Gallup Earth Day Poll), split public/private.
- **Study 2** — International ISSP data collected 2020. Not yet incorporated.

**Key files:**
- `environ-beliefs.qmd` — main manuscript (renders to HTML, PDF, DOCX)
- `scripts/analysis.R` — data loading, network estimation, bootstrap loading, and centrality objects sourced by the manuscript
- `scripts/Data cleaning script.R` — builds `data/cleandat.csv` from `data/apsa17.csv`
- `scripts/export-cited-refs.R` — pre-render step that trims the master `.bib` to cited keys
- `data/cleandat.csv` — cleaned Study 1 analysis file (*N* = 501)
- `README.md` — project structure and reproduction instructions

---

## Session History

### Session 1 — 2026-09-10 (Project set-up, incorporate earlier version)

- Ran the `CLAUDE.md` "set-up" workflow, folding in directories and files
  from an earlier version of the project.
- Copied the standard project scaffolding from `project-files/`: `_quarto.yaml`,
  `README.md`, `LOG.md`, `custom-reference-doc.docx`, `nowlin-style-profile.md`,
  `scripts/export-cited-refs.R`, and `template.qmd`.
- **Manuscript:** renamed `template.qmd` → `environ-beliefs.qmd` at the project
  root (the earlier version kept it in `manuscript/`). Set the YAML title to
  the project title; added `\usepackage{ulem}` to the PDF header (needed by
  the template's `\normalem`). Moved the earlier manuscript's prose (Data and
  Measures / Measures sections) in verbatim, plus the two qgraph network
  figure chunks (`fig-envNetwork`, `fig-combineNetwork2`), now driven by
  grouping vectors exported from `analysis.R`.
- **Analysis:** created `scripts/analysis.R` from the earlier `analysis-draft.R`
  and the earlier qmd's code chunks. It loads `data/cleandat.csv`, computes
  scale reliabilities (α: composite .79, private .75, public .76, NEP .82,
  CNS .81 — matches the manuscript prose), estimates the two EBICglasso
  networks (beliefs only; beliefs + public/private behavior), `load()`s the
  pre-computed nonparametric bootstrap objects, and builds the betweenness/
  closeness/strength centrality frames, the per-panel and faceted centrality
  plots (written to `output/`), and CNS-vs-NEP centrality *t*-tests
  (all n.s.). The two `net_boot` objects from the earlier chunks were
  disambiguated (`env_boot`, `envB_boot`); all paths made project-relative.
- **File consolidation:**
  - `manuscript/` data files (`cleandat.csv`, `*network_data_for_replication.RData`)
    were byte-identical duplicates of `data/` — removed the duplicates and the
    now-empty `manuscript/` folder.
  - `manuscript/environ-beliefs.pdf` (earlier render) → `output/environ-beliefs_2025-10-03_earlier-draft.pdf`.
  - `manuscript/environ-beliefs.qmd` (earlier single-file manuscript) →
    `scripts/_earlier-version-manuscript.qmd.bak` for reference.
  - Removed the obsolete one-off `scripts/set-up.r` (hardcoded Dropbox paths,
    superseded by this workflow).
  - Kept `scripts/analysis-draft.R` and `scripts/Data cleaning script.R`,
    plus `data/apsa17.csv` and the SSI codebook.
- `_quarto.yaml`: set the render target to `environ-beliefs.qmd`.
- `export-cited-refs.R`: set the manuscript filename to `environ-beliefs.qmd`.
- Added `.gitignore` (ignores `/data`, `/literature`, `nowlin-style-profile.md`,
  generated `references.bib`/`.csl`, R/Quarto scratch; keeps `_output/`).
- Initialized `renv` and wrote a lockfile.
- Initialized git, created the public GitHub repo, and pushed.
- Redacted the absolute `project-files` path from `CLAUDE.md` before the
  first commit.
- **Render check:** `quarto render` produces HTML, PDF (LuaLaTeX), and DOCX
  cleanly.

### Session 2 — 2026-09-10 (Bring in ISSP 2020 data for Study 2; question crosswalk)

- Added `scripts/convert-issp.R`: reads the ISSP 2020 Environment SPSS file
  (`ZA7650_v2-0-0.sav`, kept outside the repo in `03-data/`), `zap_missing()`
  + `zap_labels()`, and writes:
  - `data/issp_environment_2020.csv` — 44,100 respondents × 337 variables,
    28 countries (US `country == 840`, *n* = 1,847). ISSP reserved codes
    (−9/−8/−7/−4/−1) collapsed to `NA`; raw `.sav` keeps them distinct.
  - `data/issp_environment_2020_codebook.csv` — `variable, label` for all 337.
- Copied the ISSP source questionnaire to
  `data/ISSP_ZA7650_questionnaire.pdf`.
- Wrote `data/issp-2017-crosswalk.md`: item-level map from the Study 1
  belief/behavior measures to ISSP 2020 items, each rated Strong / Moderate /
  Weak / None, with both questionnaires' wording quoted and the recoding
  needed to align response-scale direction (ISSP agree items run 1 = agree
  strongly … 5 = disagree strongly, opposite to the scored 2017 NEP/CNS).
  Headline findings:
  - **Behaviors** map reasonably: recycle→`v52`, give money→`v56`,
    petition→`v55` (Strong); avoid products→`v53`, group membership→`v54`
    (Moderate). 6 of the 13 Gallup items have usable ISSP equivalents;
    contacting officials/business, env-motivated voting, and water/energy
    saving do not.
  - **NEP** has no ISSP scale but Q10/Q12 items cover the same facets
    (`v34` ≈ "crisis exaggerated", `v20` ≈ "science will solve it").
  - **CNS** — essentially no ISSP equivalent (only `v46` "enjoy being outside
    in nature" as a thin proxy). Largest gap.
  - **Cultural cognition** — only a 2-item economic-individualism proxy
    (`v3`, `v4`); the egalitarian–hierarchical scale has no ISSP analog.
  - **Environmentalist / movement identity** — gap. Ideology → `PARTY_LR`
    (left–right from vote choice; ~44% missing pooled).
  - Section 7 gives a recommended ISSP node set for the Study 2 network and
    the full gap list. Study 2 is best framed as a partial, mostly
    attitudinal replication.
- All Study 2 files land in `data/` and are therefore git-ignored;
  `scripts/convert-issp.R` is the only tracked addition.

---

## Analysis Architecture (as of Session 1)

All Study 1 analysis is centralized in `scripts/analysis.R`, sourced at the
top of `environ-beliefs.qmd`. The script:

- Loads `data/cleandat.csv`.
- Computes Cronbach's α for the behavior composite/private/public scales and
  for NEP, CNS, CC-CI, CC-EH.
- Estimates two Gaussian graphical models with `bootnet::estimateNetwork`
  (`default = "EBICglasso"`, `corMethod = "cor_auto"`, `tuning = 0.5`):
  - `envNetNetwork` — 32 belief nodes (ideology, 2 environmentalist-identity
    items, 14 CNS items, 15 NEP items).
  - `envBNetNetwork` — the same 32 nodes plus `public` and `private` behavior.
- `load()`s the pre-computed nonparametric bootstraps
  (`data/ENVnetwork_data_for_replication.RData`,
  `data/ENVBnetwork_data_for_replication.RData`; 1000 reps each). Regeneration
  code is in comments at each `load()`.
- Builds tidy centrality frames (`centrality_frame()` helper) and per-measure
  point-range panels (`centrality_panel()` helper); `egg::ggarrange`s the
  three panels and writes `output/ENVcentralPlots.png` /
  `output/ENVBcentralPlots.png`.
- Classifies belief nodes as CNS / NEP / Ideology / ENV and tests whether CNS
  vs. NEP nodes differ in mean betweenness/closeness/strength
  (`btwCOMP.t`, `clsCOMP.t`, `strCOMP.t` — all non-significant); writes the
  faceted by-type crossbar plot `output/centP.png`.

The two qgraph network figures are drawn in code chunks in the qmd
(`fig-envNetwork`, `fig-combineNetwork2`) using the `envNetGroups` /
`envBNetGroups` factors exported from `analysis.R`.

## Key Analytical Decisions

- **Network estimation:** EBICglasso (`bootnet`/`qgraph`) with `cor_auto`
  (polychoric/polyserial where items are ordinal) and hyperparameter
  `tuning = 0.5`. EBICglasso flagged a dense solution (`lambda < 0.1 *
  lambda.max`) for both networks — noted for interpretation of the smallest
  edges.
- **Centrality inference:** nonparametric bootstrap (1000 reps),
  betweenness / closeness / strength, pre-computed and cached as `.RData`.
- **Behavior in the network:** entered as the `public` and `private`
  sub-scale sums (not the 13 individual behavior items) in `envBNetNetwork`.

## Open Items / To Do

- **Study 2 (ISSP 2020)**: data + questionnaire + a Study 1↔ISSP question
  crosswalk are in `data/` (git-ignored); conversion is `scripts/convert-issp.R`.
  Still to do: pick the final ISSP node set, build the Study 2 network(s),
  and decide US-only vs. pooled/cross-national. No manuscript prose yet.
- The manuscript prose sections `# Introduction`, `# Explaining
  Pro-Environmental Behavior`, `# Belief System Networks`, `# Belief System
  Network Analysis`, and `# Results` are still empty headers.
- No `references.bib` keys are cited yet (pre-render export writes an empty
  bib, which is handled).
- "Table 1" (scale summary statistics + correlations) is referenced in the
  prose but not yet built as a code chunk.
- Centrality figures are written to `output/` but not yet placed in the
  manuscript with `@fig-` labels.
- `scripts/analysis.R` still carries the `car` / `ppcor` / `modelsummary` /
  `NetworkComparisonTest` library calls inherited from the earlier draft;
  trim to what's actually used once the analysis settles.
