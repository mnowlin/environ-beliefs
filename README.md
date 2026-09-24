# Environmental Belief System Networks and Pro-Environmental Behavior

Manuscript and reproducible analysis examining how environmental beliefs are
connected in belief-system networks and which beliefs sit on the shortest
paths to self-reported pro-environmental behavior.

The paper uses international data from the **ISSP 2020 Environment** module
(ZA7650; 44,100 respondents, 28 countries).

- **Belief nodes (9):** built from the EGA scale communities, oriented so
  higher = more pro-environmental — willingness to sacrifice (`willing`,
  4 items), ecological worldview (`worldview`), perceived threat (`threat`),
  nature affinity (`nature`), and two single items split off the EGA
  commitment community, environmental concern (`concern`, Q6) and personal
  impact (`impact`, Q12g) — plus three single items: left–right ideology
  (`left_right`, vote-based `PARTY_LR`), support for private enterprise
  (`market`, Q2a) and support for government redistribution
  (`redistribute`, Q2b). Node definitions: `issp_node_map` in
  `scripts/_issp-scale-defs.R`.
- **Behavior nodes (2):** public (group membership, petition, donation,
  protest) and private (recycling, avoiding harmful products).
- **Method:** one regularized partial-correlation network (EBICglasso via
  `bootnet`/`qgraph`) per country plus a pooled network, and weighted shortest
  paths (Dijkstra on 1/|edge weight|) from each belief to each behavior, with
  1,000-resample nonparametric bootstraps per country.

An earlier version also had a **Study 1** (US, July 2017, *N* = 1,000;
NEP, CNS, identity, ideology; 13-item Gallup behavior scale). It has been
dropped from the manuscript; its code (`scripts/analysis.R`,
`scripts/Data cleaning script.R`) and supplement section S1 remain in the
repo.

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
  analysis.R                          (Former Study 1) sourced by the qmd; the manuscript now
                                        only uses net_fig_cols from it. Also the S1 EGA/UVA objects
  analysis-issp-scales.R             Study 2: EGA scale development (see data/issp-scales.md)
  analysis-issp.R                     Study 2: per-country + pooled ISSP belief->behavior networks
                                        (9 belief nodes, public/private behavior; bootstrap CIs),
                                        pooled belief-only network. MODES adds the 6-item variant
  robustness-envcom.R                Study 2 robustness: envcom without its willingness-to-pay /
                                        personal-norm items (lean) and with them as a separate node (split)
  _spl-bootstrap.R                   Shared: boot_spl() bootstrap of belief->behavior shortest paths
  _issp-scale-defs.R                 Shared: ISSP scale maps (EGA scales; issp_node_map = network
                                        nodes) + make_issp_scales() helper
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
  issp_belief_behavior_*_pubpriv.csv  Study 2 shortest paths / per-country summaries (+ bootstrap)
  issp_networks_by_country_pubpriv.rds  Fitted country + POOLED networks
  issp_pooled_belief_network.rds      Pooled belief-only network
  issp_spl_boot_pubpriv.rds           Per-country bootstrap cache (delete to rebuild after node changes)
  issp_robust_envcom_*.csv            Output of scripts/robustness-envcom.R
  issp_node_alpha.rds                 Pooled alpha of each multi-item node scale
  archive-5belief/, archive-7belief/, archive-8belief/
                                      Study 2 outputs from earlier node sets (see LOG Sessions 14-15)
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
  `Rscript scripts/robustness-envcom.R` runs the environmental-commitment
  robustness variants.
- **renv on OneDrive:** set `RENV_CONFIG_CACHE_SYMLINKS=FALSE` (e.g. in
  `~/.Renviron`) before `renv::restore()`. OneDrive turns renv's cache
  symlinks into plain-text stubs, which leaves packages unloadable.

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
