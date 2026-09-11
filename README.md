# Environmental Belief System Networks and Pro-Environmental Behavior

Manuscript and reproducible analysis examining how environmental beliefs are
connected in belief-system networks and which beliefs sit on the shortest
paths to self-reported pro-environmental behavior.

The paper has two studies:

- **Study 1** — US data collected in July 2017 (*N* = 1,000 adults), fielded
  online through Survey Sampling Inc. Belief items are political ideology,
  environmentalist identity, the Connectedness to Nature Scale (CNS), and the
  New Ecological Paradigm (NEP). Behavior is a 13-item pro-environmental
  behavior scale (2000 Gallup Earth Day Poll), split into public and private
  sub-scales. The 2017 survey also carried cultural-cognition batteries
  (egalitarian–hierarchical, communitarian–individualist), but those were a
  split-ballot shown to only 501 of the 1,000 respondents, so cultural
  cognition is **not** used — dropping it keeps the network at the full *N* =
  1,000.
- **Study 2** — International data from ISSP 2020 Environment (ZA7650;
  44,100 respondents, 28 countries). Data are imported and there is a
  Study 1 ↔ ISSP question crosswalk (`data/issp-2017-crosswalk.md`); the
  Study 2 network analysis is not yet written.

The Study 1 network has five belief nodes — political ideology,
environmentalist identity, environmental-movement identity, and the NEP and
CNS **scale scores** (item means, oriented so higher = more
pro-environmental) — plus public and private behavior nodes. It is a
regularized partial-correlation network (EBICglasso via `bootnet`/`qgraph`)
with nonparametric-bootstrap node centrality (betweenness, closeness,
strength) and weighted shortest paths (Dijkstra on 1/|edge weight|) from each
belief to the two behavior nodes. Appendix A (EGA / UVA, `EGAnet`) documents
why the NEP and CNS items are collapsed to single scales.

## Layout

```
environ-beliefs.qmd                   Manuscript source (renders to HTML, PDF, DOCX)
environ-beliefs-supplement.qmd        Supplemental materials (S1 Study 1 EGA/UVA; S2 Study 2 scale
                                       construction; S3 Study 2 by-country results)
_quarto.yaml                          Quarto project config
_output/                              Rendered HTML/PDF/DOCX (tracked in git)
custom-reference-doc.docx             Word reference template used for the DOCX output
LOG.md                                Running session log (newest entry first)
scripts/
  analysis.R                          Sourced by the qmd: builds NEP/CNS scale scores,
                                        estimates the belief and belief+behavior networks,
                                        centrality + bootstrap, belief->behavior shortest
                                        paths, and the Appendix A EGA/UVA objects
  analysis-issp-scales.R             Study 2: EGA scale development (see data/issp-scales.md)
  analysis-issp.R                     Study 2: per-country ISSP belief->behavior networks (scale nodes,
                                        public/private behavior; bootstrap CIs). MODES adds the 6-item variant
  _spl-bootstrap.R                   Shared: boot_spl() bootstrap of belief->behavior shortest paths
  _issp-scale-defs.R                 Shared: ISSP scale maps + make_issp_scales() helper
  export-cited-refs.R                 Pre-render step: trims the master .bib to cited keys
  Data cleaning script.R              Builds data/cleandat.csv from data/apsa17.csv
  convert-issp.R                      Converts the ISSP 2020 SPSS file to data/issp_environment_2020.csv
  _earlier-version-manuscript.qmd.bak Prior single-file manuscript, kept for reference
data/                                 Survey data + bootstrap objects (NOT in git -- see below)
  apsa17.csv                          Raw 2017 US survey export (SSI)
  cleandat.csv                        Cleaned Study 1 analysis file (N = 1,000)
  ENVnetwork_data_for_replication.RData    Bootstrap cache, beliefs-only network (auto-rebuilt)
  ENVBnetwork_data_for_replication.RData   Bootstrap cache, beliefs + behavior network (auto-rebuilt)
  ega_boot_study1.RData                    bootEGA cache for Appendix A (auto-rebuilt)
  Values and Environmentalism Ques_4 to SSI-Codebook.docx   2017 questionnaire/codebook
  issp_environment_2020.csv           ISSP 2020 Environment (ZA7650), 44,100 x 337, 28 countries
  issp_environment_2020_codebook.csv  variable -> question-label map for the ISSP file
  ISSP_ZA7650_questionnaire.pdf       ISSP 2020 source questionnaire
  issp-2017-crosswalk.md             Study 1 <-> ISSP item map for beliefs and behaviors
output/                               Figure PNGs written by analysis.R (centrality plots)
literature/                           Background literature (NOT in git -- local only)
```

## Reproducing the analysis

Requires R with: `tidyverse`, `bootnet`, `qgraph`, `egg`, `car`, `ppcor`,
`modelsummary`, `networktools`, `NetworkComparisonTest`, `psy`, `EGAnet`,
`patchwork`. Package versions are pinned with `renv` (`renv::restore()`).

- **Manuscript:** `quarto render` → outputs to `_output/`
  (HTML, PDF, and DOCX; the DOCX uses `custom-reference-doc.docx`)
- **Analysis only:** `Rscript scripts/analysis.R` builds every Study 1 object
  and figure PNG without rendering the manuscript.
- **ISSP import:** `Rscript scripts/convert-issp.R` (needs `haven`; reads the
  `.sav` from `03-data/`) rebuilds `data/issp_environment_2020.csv`.
- **Study 2:** `Rscript scripts/analysis-issp-scales.R` develops the belief
  scales (EGA), then `Rscript scripts/analysis-issp.R` builds the per-country
  belief→behavior networks and `data/issp_belief_behavior_*.csv`.

The node-centrality bootstraps (`ENV*network_data_for_replication.RData`) and
the bootEGA cache (`ega_boot_study1.RData`) are written to `data/` on first
run and reloaded thereafter; delete them to force a rebuild after changing
the node set.

## Data

The `data/` folder is **not tracked in git**. Restore it before rendering.

- `data/cleandat.csv` — cleaned Study 1 analysis file (*N* = 1,000). Built
  from `data/apsa17.csv` by `scripts/Data cleaning script.R` (scale
  construction, reverse-coding, behavior dummies, public/private/composite
  indices). The `cc_ci_*` / `cc_eh_*` (cultural cognition) columns are present
  but populated for only 501 respondents (split-ballot, `dumqset1shown`) and
  are not used by `scripts/analysis.R`.
- `data/apsa17.csv` — raw survey export from Survey Sampling Inc.
- `data/issp_environment_2020.csv` — ISSP 2020 Environment module (ZA7650
  v2-0-0), converted from the archive `.sav` by `scripts/convert-issp.R`.
  ISSP reserved missing codes (−9/−8/−7/−4/−1) are set to `NA`. See
  `data/issp-2017-crosswalk.md` for how its items line up with the 2017
  measures; the raw `.sav` is not in the repo (`03-data/`).

## Notes

- `references.bib` and the local `.csl` are generated at render time by the
  pre-render step (`export-cited-refs.R`) from the master bibliography, so
  they are git-ignored.
- `_output/` **is tracked in git** (unlike most build artifacts) so the
  rendered manuscript is available without re-running R/Quarto. Re-render
  (`quarto render`) after any change to `environ-beliefs.qmd` or
  `scripts/analysis.R` and commit the updated files in `_output/`.
- Quarto's freeze cache (`_freeze/`) is enabled (`execute: freeze: auto` in
  `_quarto.yaml`), so code chunks are only re-executed when the qmd or its
  upstream R sources change.
- `literature/` and `nowlin-style-profile.md` are git-ignored (local only).
- `LOG.md` records what changed and why for each work session; add a new
  entry at the top.
