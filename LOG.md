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
- **Study 2** — International ISSP data collected 2020.

> **As of Session 14 the paper uses Study 2 (ISSP 2020) only.** Study 1 is
> dropped from the manuscript; its code and data remain in the repo.

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
- Close-out: refreshed `README.md` for the Study 2 files and
  `scripts/convert-issp.R`; committed and pushed.

### Session 3 — 2026-09-10 (Drop cultural cognition from Study 1; Study 1 N is 1,000)

- Established that `data/apsa17.csv` / `data/cleandat.csv` have **1,000**
  rows, not 501. The cultural-cognition batteries (`q1x31_*` → `cc_ci_*`,
  `cc_eh_*`, "Question Set 1") were a split-ballot (`dumqset1shown`) shown to
  501 respondents; the other 499 saw an alternative item set
  (`q101x127_*`). NEP, CNS, environmentalist identity, ideology, and the
  13 behavior items were asked of all 1,000.
- Consequence: the belief-system network already excluded cultural-cognition
  nodes and the cached bootstraps were already estimated on N = 1,000
  (`env_boot$sampleSize == envB_boot$sampleSize == 1000`). So the network
  itself does **not** change.
- `scripts/analysis.R`: removed the now-vestigial `ccciA` / `ccehA` Cronbach
  computations (they ran on the 501 split-ballot subset and fed nothing);
  added `n_study1 <- nrow(CCdata)` and a header note on the split ballot.
  Re-ran: alphas and both bootstrap objects unchanged, N = 1,000.
- Corrected the "501" figure and the cultural-cognition framing in
  `README.md` and `data/issp-2017-crosswalk.md` (crosswalk §5c kept as
  reference only; egal–hier removed from the §7 gap list).
- **`environ-beliefs.qmd` still needs an author edit**: the Data and Measures
  paragraph says "cultural cognition … a sample of 501 adults" — the sample
  is 1,000 and cultural cognition is no longer part of the study.

### Session 4 — 2026-09-10 (Study 2: per-country belief -> behavior networks)

- Added `scripts/analysis-issp.R`: for each of the 28 ISSP countries (+ a
  pooled reference) estimate an EBICglasso network over individual belief and
  behavior items (no indices), then compute Dijkstra shortest paths
  (1/|edge weight|) from every belief node to every behavior node -- the
  Study 1 method applied to ISSP.
  - Belief nodes matched to the 2017 constructs: NEP -> `v20`-`v25`,`v34`;
    CNS -> `v46`,`v47`; environmentalist identity -> `v31` (weak proxy);
    ideology -> `PARTY_LR`. Movement identity has no ISSP item (omitted).
  - Behavior nodes: `v52`-`v57` (the six ISSP items with a 2017 Gallup-list
    analog), kept individual.
  - Recoding per `data/issp-2017-crosswalk.md` §3; nodes that are
    (near-)constant or >50% missing in a country are dropped and logged
    (`PARTY_LR` dropped in 10 countries incl. CN/TW).
- Outputs (git-ignored): `data/issp_belief_behavior_paths.csv`,
  `data/issp_belief_behavior_summary.csv`, `data/issp_networks_by_country.rds`,
  `output/issp/issp_networks_by_country.pdf`, and a write-up in
  `data/issp-belief-behavior-results.md`.
- Result: `do_right` (identity/commitment proxy) or `left_right` (ideology)
  is the belief closest to the behavior set in 17/28 countries; abstract
  NEP-type worldview items are consistently farthest. Mirrors Study 1 and
  Brandt et al. Stability/bootstrap CIs not yet done -- flagged in the
  results doc.

### Session 5 — 2026-09-10 (Study 1 appendix: EGA / UVA of NEP and CNS)

- Added `EGAnet` (renv snapshot updated) and an "APPENDIX" section to
  `scripts/analysis.R`:
  - `EGA()` on the 15 NEP items, the 14 CNS items, and both jointly
    (glasso model, Walktrap communities); `bootEGA()` 500 resamples for
    structural / item stability, cached to `data/ega_boot_study1.RData`
    (regeneration code in the script).
  - `UVA()` redundancy check (wTO, cut-offs 0.25 and 0.20).
  - `net.scores()` single-dimension EGA network score per scale, sign-aligned
    and reversed so higher = more pro-environmental; correlation matrix
    against the raw mean, a UVA-reduced NEP mean, and `public` / `private`.
- **Finding:** both scales' EGA solutions split into two communities that map
  onto item *keying* (forward vs reverse-worded), not content facets --
  a wording/method factor. bootEGA: NEP 2-dim modal in 85% of resamples
  (structural consistency .75/.78), CNS 2-dim in 68% (.59/.93). UVA flags no
  pair above wTO 0.25, so nothing is collapsed. EGA network score vs raw mean
  correlate .99 (NEP) / .97 (CNS) and relate to behavior near-identically.
  Conclusion: treat NEP and CNS each as one dimension; keep the raw means.
- `environ-beliefs.qmd`: added "## Appendix A. Dimensionality of the NEP and
  CNS scales" under `# Appendix` -- `@fig-ega` (3-panel EGA plot),
  `@tbl-ega-stability`, `@tbl-ega-comm`, `@tbl-uva`, `@tbl-ega-scorecor`,
  plus connective text (review/expand the prose). Added a `\setcounter{figure}`
  / `\thefigure` A-prefix line to the existing latex appendix block.
  Cross-refs resolve; HTML/PDF/DOCX render clean (PDF now 8 pp). Note the
  A-prefix only takes in the PDF (the latex hack); in HTML/DOCX the appendix
  items keep continuous numbers -- switch the heading to
  `# Appendix {.appendix}` if cross-format A-numbering is wanted.

### Session 6 — 2026-09-10 (Study 1: NEP and CNS collapsed to single scale nodes)

- Per decision (motivated by the Session 5 EGA/UVA appendix), the Study 1
  network now uses **scale scores**, not individual items:
  - `scripts/analysis.R` builds `nepX_pro` / `cnsX_pro` = `6 - item` for every
    NEP/CNS item so higher = more pro-environmental, then
    `CCdata$NEP` / `CCdata$CNS` = the item means (equal to the cleaning
    script's `6 - mean`). Confirmed: `cor(NEP, public/private)` = .17/.30,
    `cor(CNS, ...)` = .36/.43 -- all positive.
  - Node set: `envNetVars` = Ideology, environmentalist, enviro.move, NEP,
    CNS (5); `envBNetVars` adds public, private (7). Grouping factors and the
    `fig-envNetwork` / `fig-combineNetwork2` plots updated.
  - Dropped the item-level CNS-vs-NEP centrality comparison (`btwCOMP.t` etc.,
    `centP`, `output/centP.png`) -- meaningless with one node per scale.
  - Bootstrap caches now load-or-generate (`run_bootnet()`); the stale
    32/34-node `ENV*network_data_for_replication.RData` were deleted and
    rebuilt for the 5/7-node networks (~30 s each). Also removed the orphaned
    `COM*network_data_for_replication.RData` and `output/COM*`, `output/centP.png`.
- Added **RESULTS 3** to `analysis.R`: `belief_behavior_spl` -- weighted
  shortest-path distance (`qgraph::centrality(...)$ShortestPathLengths`,
  Dijkstra on 1/|edge weight|) from each belief node to `public` / `private`,
  plus the direct partial correlations. `environ-beliefs.qmd` gains
  `### Shortest paths from beliefs to behavior` with `@tbl-spl`.
- Result (scale-level): environmentalist identity is closest to public
  behavior (dist 2.75; direct edge r = .36), CNS closest to private (3.84;
  r = .26), then enviro.move; NEP and ideology are farthest. Same ordering
  as the earlier item-level exploration, now stable on 5-7 nodes.
- `renv.lock` updated (EGAnet, patchwork). HTML/PDF/DOCX render clean.
- Still no bootstrap CIs on the shortest-path distances (a resampling wrapper
  is the remaining to-do).
- User trimmed the Study 1 "Data and Measures" prose (dropped the
  cultural-cognition framing and the "501 adults" sentence; merged headings
  under `# Study 1`). Built the referenced-but-missing **Table 1**:
  `descriptives_table` in `analysis.R` (M / SD / min / max + lower-triangle
  correlations for PEB, public, private, NEP, CNS, ideology, environmentalist
  identity, movement identity) and a `@tbl-descriptives` chunk after the
  measures text. NB the Study 1 section now has no sentence stating the
  sample (N = 1,000, SSI, online, July 2017) -- flag for the author.

### Session 7 — 2026-09-10 (Study 2 belief scales via EGA)

- `scripts/analysis-issp-scales.R`: EGA scale development for Study 2 from the
  28-item candidate pool in `issp-2017-crosswalk.md` §7 (v15, v17, v20-v25,
  v26-v29, v30-v36, v37-v43, v46, v47; `PARTY_LR` kept as a single ideology
  node, not scaled).
  - Compared groupings by TEFI (lower = better): a-priori batteries -21.0,
    Walktrap 3-comm -26.2, **Louvain / EGA.fit 5-comm -31.4 (best)**. Every
    item-drop variant fit worse. `bootEGA` 500 resamples: 5 comms in 95% of
    resamples, structural consistency >= .95. Q10 and Q12 each split by item
    keying (same wording artifact as Study 1 NEP/CNS); Q11 and Q13 are
    unidimensional.
  - Recommended **4-scale set** (fold the 2-item v22/v25 "limits" community
    into worldview, mirroring the Study 1 NEP decision), all oriented
    higher = pro-environmental:
    `envcom` (v15,v26,v27,v28,v31,v36; alpha .75),
    `worldview` (v17,v20-v25,v29,v30,v32-v35; .76),
    `threat` (v37-v43; .80),
    `nature` (v46,v47; .61 -- thin CNS proxy).
  - `make_issp_scales(df, map)` helper builds the scales inside any subset.
    `envcom`/`worldview` relate most to behavior; `PARTY_LR` (after recoding
    "other"/"invalid" to NA) correlates ~-.22 with the attitude scales
    (right = less pro-env) but is 47% missing pooled.
- Outputs (git-ignored): `data/issp_scale_scores_pooled.csv`,
  `data/issp_ega_boot.RData`, write-up `data/issp-scales.md`; crosswalk §7
  points to it.

### Session 8 — 2026-09-10 (Rebuild per-country ISSP networks with scale nodes)

- Extracted the scale machinery into `scripts/_issp-scale-defs.R`
  (`issp_reverse`, `orient_issp`, `issp_scale_map_4/5`, `make_issp_scales`),
  now sourced by both `analysis-issp-scales.R` and `analysis-issp.R`.
- Rewrote `scripts/analysis-issp.R`: belief nodes are now the four scale
  scores (`envcom`, `worldview`, `threat`, `nature`) + `left_right`
  (`PARTY_LR`); behavior nodes stay the six individual items
  (`recycle`, `avoid_buy`, `group_member`, `petition`, `donate`, `protest`).
  Per country: build scales, recode, drop near-constant / >50%-missing nodes,
  EBICglasso (`cor_auto`, `forcePD = TRUE` -- fixes JP, whose ~1%-yes protest
  item made the polychoric matrix non-PD), then belief->behavior shortest
  paths. All 28 countries + POOLED now fit.
- Result: **`envcom` is the belief closest to the behavior set in 14/28
  countries** (mean rank 2.14), `worldview` next (2.25), `left_right` 2.44
  where present; `threat` and `nature` are peripheral (3.46, 3.79). Mirrors
  Study 1 (commitment/identity node closest) and the earlier item-level ISSP
  run. `data/issp-belief-behavior-results.md` rewritten for the scale nodes.
- Same output files as before (overwritten): `issp_belief_behavior_paths.csv`,
  `issp_belief_behavior_summary.csv`, `issp_networks_by_country.rds`,
  `output/issp/issp_networks_by_country.pdf`.
- Still open: bootstrap CIs on the shortest-path distances.

### Session 9 — 2026-09-10 (Study 2: add public/private behavior mode)

- `scripts/analysis-issp.R` now runs **two behavior modes** in one pass, with
  all outputs suffixed `_items` / `_pubpriv` (the old unsuffixed files were
  removed):
  - `items` -- the 6 individual behavior items (as before).
  - `pubpriv` -- `public` = group_member+petition+donate+protest (0-4 count);
    `private` = recycle+avoid_buy, each dichotomised to "always/often" = 1
    (0-2 count). Parallels the Study 1 public/private nodes.
- Added an **EGA check on the 6 behavior items** (pooled): Louvain and
  Walktrap both recover the 2/4 split exactly (private = recycle/avoid_buy;
  public = the other four; TEFI -2.7), confirming the pubpriv grouping.
- Result: `pubpriv` mode makes **`envcom` closest to behavior in 24/28
  countries** (mean rank 1.25, vs 14/28 in `items` mode) -- collapsing the
  behavior side sharpens the commitment node's lead. Pooled: `envcom`->public
  (3.92) is the shortest path of all. `data/issp-belief-behavior-results.md`
  rewritten to cover both modes.
- Still open: bootstrap CIs on the shortest-path distances.

### Session 10 — 2026-09-10 (Study 2 manuscript prose; supplemental-materials file)

- **`environ-beliefs.qmd`**: added draft Study 2 `## Data and Measures` and
  `## Results` prose (brief, in the author's style -- first person, "likely",
  "As noted", no section cross-refs, no colons), with inline R and a new
  `@tbl-issp-results` (mean belief rank across the 28 countries, both behavior
  modes). Added one sentence to the Study 1 measures pointing to the
  supplement for the NEP/CNS dimensionality check.
- **Moved** the entire manuscript Appendix A (Study 1 EGA/UVA -- prose +
  `fig-ega`, `tbl-ega-*`) into a new **`environ-beliefs-supplement.qmd`** as
  section S1. The `# Appendix` heading and its latex A-counter block are
  removed from the main manuscript.
- New supplement sections: **S2** (construction of the Study 2 belief scales
  -- TEFI structure comparison, the 5 EGA communities, bootEGA stability, the
  4 final scales + alpha, scale correlations, and the behavior-item EGA that
  recovers the public/private split) and **S3** (belief closest to behavior
  in each country, both modes).
- `analysis-issp-scales.R` now also runs the 6-item behavior EGA and saves a
  display bundle `data/issp_scale_dev.rds` for the two qmds.
- `_quarto.yaml` renders both docs; `export-cited-refs.R` scans both.
- HTML/PDF/DOCX render clean for the manuscript and the supplement.

### Session 11 — 2026-09-10 (Bootstrap CIs on the shortest-path distances)

- `scripts/_spl-bootstrap.R`: `boot_spl()` -- nonparametric bootstrap
  (resample respondents with replacement, re-estimate EBICglasso, recompute
  Dijkstra belief->behavior shortest paths), returning per-pair percentile
  CIs, per-belief mean-distance CIs, and `closest_freq` (proportion of
  resamples in which each belief is closest to the behavior set). Parallel
  over draws via `parallel::mclapply`.
- **Study 1** (`analysis.R`): 1,000 resamples on `envBNetNetwork`, cached to
  `data/ENVB_spl_bootstrap.RData`. `tbl-spl` now shows each distance with its
  95% interval. `environmentalist` is the closest belief to the behavior set
  in ~96% of resamples; `environmentalist`->public = 2.7 [2.3, 3.5] and
  `CNS`->private = 3.8 [3.1, 5.2] are clearly separated, the rest overlap.
- **Study 2** (`analysis-issp.R`): 1,000 resamples per country per mode,
  checkpointed to `data/issp_spl_boot_<mode>.rds` after each country. The
  summary CSVs gain `mean_spl_lo/hi` and `p_closest`. The POOLED network
  (44k respondents, reference only) keeps its point estimate -- bootstrapping
  it was the bottleneck; `NCORES` capped at 8 (13 oversubscribed and ran ~5x
  slower).
- **Study 2 finding:** the country-level ordering is much more stable under
  the public/private specification -- the rank-1 belief holds in a majority
  of resamples in 27/28 countries (20 at > 80%) vs only 16/28 (4 at > 80%)
  for the six-item specification. The cross-country regularity (`envcom`
  closest on average) is the reliable part.
- Supplement S3 by-country table carries the bootstrap support per country;
  the manuscript Study 2 Results and `data/issp-belief-behavior-results.md`
  updated with the robustness numbers.

### Session 12 — 2026-09-10 (Study 2 = public/private behavior only)

- Per decision, Study 2 in the manuscript and supplement now uses **only the
  public/private behavior specification**, to match Study 1. The six-item
  version is retained in `analysis-issp.R` as an unreported robustness variant
  (`MODES <- c("pubpriv")` by default; add `"items"` to regenerate it).
- `environ-beliefs.qmd`: Study 2 Data and Measures describes only the
  public/private indices; Results reports only that specification; Table 3 is
  now one specification (Belief / Mean rank / Closest in / Bootstrap-supported).
  `envcom` closest in 24/28 countries, bootstrap-supported in 27/28.
- `environ-beliefs-supplement.qmd`: S3 by-country table is public/private only
  (Belief / distance [95% CI] / bootstrap support), with one sentence noting
  the six-item variant was also run and is noisier.
- Both documents render clean (HTML/PDF/DOCX).

### Session 13 — 2026-09-10 (Study 2: illustrative country-network figure)

- `environ-beliefs.qmd`: added **Figure 3**, a 2x2 panel of the pubpriv belief
  networks for four countries chosen to span the range -- CH (typical,
  `envcom` closest, p = 1.00), US (near three-way tie, p_closest .47/.28/.25),
  IN (`nature` closest, p = .98), AU (`left_right` closest, p = .53). Reads
  the fitted networks from `data/issp_networks_by_country_pubpriv.rds` and
  plots each with `qgraph` (belief nodes blue, behavior nodes orange). Two
  sentences of Results prose introduce it.
- Manuscript display items: Fig 1-2 (Study 1 networks), Fig 3 (Study 2
  countries); Table 1 (descriptives), Table 2 (Study 1 shortest paths),
  Table 3 (Study 2 mean ranks).
- Recolored the Study 1 network figures (`fig-envNetwork`,
  `fig-combineNetwork2`) to match Fig 3 -- belief nodes blue
  (`#9ecae1`), behavior nodes orange (`#fdae6b`), `theme = "classic"` edges
  (green positive / red-dashed negative). `analysis.R` `node_group()` is now
  a belief/behavior binary factor and exports `net_fig_cols`; all three
  network chunks use it. Dropped the old Ideology/Identity/Orientation
  grouping and `theme = "gray"`.

### Session 14 — 2026-09-24 (Drop Study 1; economic belief nodes; envcom robustness; new figures and prose)

- **Decision: the paper is now Study 2 (ISSP 2020) only.** Assessed Study 1
  vs Study 2 consistency first: they agree coarsely (a commitment/identity
  node closest, ideology far) but not in detail (NEP far in Study 1 vs
  worldview 2nd in Study 2; CNS close to private in Study 1 vs `nature`
  mid-pack; US in Study 2 does not reproduce Study 1). Author dropped
  Study 1 for length (8,500-word limit) and to make room for a cross-country
  discussion. The Study 1 prose/figures were removed from
  `environ-beliefs.qmd` by the author; `scripts/analysis.R` is still sourced
  (only `net_fig_cols` is needed now -- candidate for trimming).
- **Robustness: is `envcom`'s lead driven by intention items?** New
  `scripts/robustness-envcom.R` (pubpriv only; outputs
  `data/issp_robust_envcom_{summary,paths}_{lean,split}.csv`,
  `data/issp_spl_boot_lean.rds`):
  - `lean` -- envcom = v15 + v36 only (alpha .41), v26-v28/v31 dropped,
    bootstrapped: envcom closest in 9/28 (mean rank 2.36); worldview 8,
    nature 7 -- three-way tie on mean rank (2.25 / 2.36 / 2.50).
  - `split` -- lean envcom + `willing` node (v26-v28, v31; alpha .78):
    `willing` closest in 15/28 (mean rank 2.04); lean envcom 3.21.
  - Conclusion: most of envcom's lead comes from its willingness-to-pay /
    "do what is right" items. **Not yet reflected in the manuscript** --
    open decision whether to report `willing` as its own node.
- **Two economic belief nodes added to Study 2** (`scripts/analysis-issp.R`):
  `market` = 6 - v3 (private enterprise best way to solve economic problems),
  `redistribute` = 6 - v4 (government should reduce income differences);
  higher = more agreement. Single-item nodes, not a scale (pooled r = -.10;
  -.47 to .17 by country). Re-ran all 28 countries + bootstrap. Old 5-belief
  outputs archived to `data/archive-5belief/`.
  - Result: rank-1 belief unchanged in every country; envcom 24/28 (mean
    rank 1.29), bootstrap-supported in 27/28. `market` (5.18) and
    `redistribute` (5.79) are the most peripheral beliefs; direct edges to
    behavior near zero. AU `left_right` support fell to .35 (now a
    three-way tie); US `nature` rose to .60.
- `analysis-issp.R` also saves the pooled belief-only network
  (`data/issp_pooled_belief_network.rds`); re-run with cached bootstraps
  reproduced the summary CSV byte-for-byte.
- **Manuscript (`environ-beliefs.qmd`)**:
  - Restored the Study 2 setup chunk (deleted along with Study 1) and added
    inline helpers (`ew`, `pool_spl`, `ctry_pc`, `mean_spl`, `mean_rank`,
    `n_no_lr`) so all prose numbers are computed.
  - New `@fig-issp-pooled` -- pooled network without / with behavior nodes,
    shared node positions (`rescale = FALSE`) and edge-width scale.
  - New `@fig-issp-spl` -- Brandt et al. (2019) Fig. 3 style: per-country
    shortest paths by belief, faceted public/private, mean +/- 95% CI boxes.
    TW `redistribute` is disconnected (Inf) and omitted.
  - Labels for the new nodes in Table/Figure code and captions.
  - Drafted Study-1-free Data and Measures and Results prose (political /
    economic beliefs paragraph, method paragraph, descriptions of every
    figure and the table, revised closing paragraph). Citations for
    glasso/EBIC, Dijkstra, and Brandt et al. still to add.
- **Supplement**: added a paragraph in S2 explaining the survey-battery
  grouping (TEFI -21.0 vs -31.4 for Louvain) and where the EGA solution
  departs from the questionnaire sections.
- **renv library repair**: OneDrive had converted renv's cache symlinks into
  text stub files (213 packages unloadable). Added
  `RENV_CONFIG_CACHE_SYMLINKS=FALSE` to `~/.Renviron`, removed the stubs,
  `renv::restore()` (copies from cache), and replaced the remaining 36
  symlinks with copies. `renv::status()` synchronized; `analysis.R` runs.
- Set `core.fileMode=false` in this repo's git config (OneDrive flips the
  executable bit, producing mode-only diffs).
- Not committed / left for the author: files OneDrive restored after earlier
  deletions (`manuscript/`, `output/COMcentralPlots.png`, `output/centP.png`,
  `output/issp/issp_networks_by_country.pdf`, `scripts/set-up.r`,
  `tmp-pdfcrop-14777.*`) and the OneDrive duplicate
  `_output/environ-beliefs-supplement_files 2/`.

### Session 15 — 2026-09-24 (Split environmental commitment into three nodes; measures table)

- **Decision (option 1 from the Session 14 robustness check): the EGA
  `envcom` community is no longer one node.** New `issp_node_map` in
  `scripts/_issp-scale-defs.R`, used by `scripts/analysis-issp.R`:
  - `willing` = v26, v27, v28, v31 (pay higher prices / taxes, cut standard
    of living, "do what is right even when it costs more"); alpha .78.
  - `concern` = v15 (single item), `impact` = v36 "environmental problems
    have a direct effect on my everyday life" (single item). First run had
    them as one 2-item scale (alpha .41); the author split them because they
    measure different things.
  - worldview / threat / nature unchanged. **9 belief nodes** in total.
  - Intermediate outputs archived: `data/archive-7belief/` (envcom + two
    economic nodes), `data/archive-8belief/` (concern+impact as one scale).
  - `analysis-issp.R` now saves `data/issp_node_alpha.rds` (pooled alpha,
    multi-item scales only).
- **Results (9 nodes, 1,000 bootstraps/country):** mean rank `willing`
  2.25 (closest in 16/28), `concern` 2.61 (8), `nature` 3.50 (4),
  `worldview` 3.50 (2), `threat` 5.75, `impact` 5.93, `left_right` 5.94,
  `market` 6.89, `redistribute` 7.36. Rank-1 belief bootstrap-supported in
  25/28. Exact ties in Denmark (concern/willing) and Finland
  (willing/worldview). Across countries the willing, concern, worldview, and
  nature shortest-path CIs overlap -- a closer group rather than a clean
  ordering. Pooled: willing -> public shortest (4.78), nature -> private
  (5.38); concern is far in the pooled network (~11) despite ranking 2nd
  across countries. `impact` sits with `threat` and has ~no direct edge to
  behavior. AU is now `concern` (.55); ideology is closest nowhere.
- **Manuscript (`environ-beliefs.qmd`)**:
  - Measures prose describes the three-way split and why.
  - New `@tbl-measures` (now Table 1): belief label, ISSP question wording
    (from `data/ISSP_ZA7650_questionnaire.pdf`, question numbers stripped at
    build time), pooled alpha for scales; (R) marks reverse-coded items.
  - All Results paragraphs rewritten for the 9-node results; closing
    paragraph contrasts general concern with perceived personal impact.
  - Setup chunk: `n_willing`, tie detection (`tie_iso`, `tie_names`, used in
    the text and in a `!expr` table caption so ties are named), `n_robust`
    counted by country, `node_alpha` / `alpha_of()`.
  - Labels/captions for `concern`, `impact`, `willing` in all figures and
    tables; "Study 2" removed from captions.
- **Supplement**: S2 paragraph explains the split of the EGA commitment
  community; S3 uses readable belief labels, "coin flip" benchmark = one
  ninth, notes how ties are shown; removed the stale six-item-variant
  sentence (not re-run with the current nodes). S1 (Study 1 NEP/CNS) is
  still in the supplement -- author to decide whether to drop it.
- `scripts/robustness-envcom.R` is kept as the record of the check that
  motivated the split (its `lean`/`split` variants predate the economic
  nodes).

---

## Analysis Architecture (as of Session 1)

> Superseded in part by Sessions 3, 5, 6: cultural cognition is dropped,
> N = 1,000, and the Study 1 network now uses **NEP/CNS scale-score nodes**
> (5 belief nodes / 7 with behavior) rather than 32 item nodes. See those
> session entries and `scripts/analysis.R`.

All Study 1 analysis is centralized in `scripts/analysis.R`, sourced at the
top of `environ-beliefs.qmd`. The script:

- Loads `data/cleandat.csv` (N = 1,000).
- Computes Cronbach's α for the behavior composite/private/public scales and
  for NEP and CNS. (Cultural-cognition α's dropped in Session 3 — split
  ballot, not used.)
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
- **Cultural cognition excluded (Session 3):** the `cc_ci_*` / `cc_eh_*`
  batteries were a split-ballot half-sample (501 of 1,000). Dropping them
  keeps Study 1 at N = 1,000; the network node set (ideology, environmentalist
  identity, CNS, NEP) never included them.

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
