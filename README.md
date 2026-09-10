# Environmental Belief System Networks and Pro-Environmental Behavior

Manuscript and reproducible analysis examining how environmental beliefs are
connected in belief-system networks and which beliefs sit on the shortest
paths to self-reported pro-environmental behavior.

The paper has two studies:

- **Study 1** — US data collected in July 2017 (*N* = 501 adults), fielded
  online through Survey Sampling Inc. Belief items include political
  ideology, environmentalist identity, the Connectedness to Nature Scale
  (CNS), the New Ecological Paradigm (NEP), and cultural-cognition
  (egalitarian–hierarchical, communitarian–individualist) batteries.
  Behavior is a 13-item pro-environmental behavior scale (2000 Gallup Earth
  Day Poll), split into public and private sub-scales.
- **Study 2** — International data from ISSP (2020). *Not yet incorporated.*

The Study 1 analysis estimates Gaussian graphical models (EBICglasso via
`bootnet`/`qgraph`), bootstraps node-centrality (betweenness, closeness,
strength) with a nonparametric bootstrap, and compares belief-type centrality
(CNS vs. NEP).

## Layout

```
environ-beliefs.qmd                   Manuscript source (renders to HTML, PDF, DOCX)
_quarto.yaml                          Quarto project config
_output/                              Rendered HTML/PDF/DOCX (tracked in git)
custom-reference-doc.docx             Word reference template used for the DOCX output
LOG.md                                Running session log (newest entry first)
scripts/
  analysis.R                          Sourced by the qmd: loads data, estimates the
                                        belief-system networks, loads the bootstrap
                                        objects, builds centrality frames/plots
  export-cited-refs.R                 Pre-render step: trims the master .bib to cited keys
  Data cleaning script.R              Builds data/cleandat.csv from data/apsa17.csv
  _earlier-version-manuscript.qmd.bak Prior single-file manuscript, kept for reference
data/                                 Survey data + bootstrap objects (NOT in git -- see below)
  apsa17.csv                          Raw 2017 US survey export (SSI)
  cleandat.csv                        Cleaned analysis file (N = 501)
  ENVnetwork_data_for_replication.RData    Bootstrap for the beliefs-only network
  ENVBnetwork_data_for_replication.RData   Bootstrap for the beliefs + behavior network
  COMnetwork_data_for_replication.RData    Bootstrap objects from earlier network variants
  COMBnetwork_data_for_replication.RData
  Values and Environmentalism Ques_4 to SSI-Codebook.docx   Questionnaire/codebook
output/                               Figure PNGs written by analysis.R (centrality plots)
literature/                           Background literature (NOT in git -- local only)
```

## Reproducing the analysis

Requires R with: `tidyverse`, `bootnet`, `qgraph`, `egg`, `car`, `ppcor`,
`modelsummary`, `networktools`, `NetworkComparisonTest`, `psy`. Package
versions are pinned with `renv` (`renv::restore()`).

- **Manuscript:** `quarto render` → outputs to `_output/`
  (HTML, PDF, and DOCX; the DOCX uses `custom-reference-doc.docx`)
- **Analysis only:** `Rscript scripts/analysis.R` estimates the networks and
  rebuilds the centrality objects and figure PNGs without rendering the
  manuscript.

The two node-centrality bootstraps are expensive, so they are pre-computed
and stored as `.RData` in `data/`. `analysis.R` `load()`s them; the code to
regenerate them is in comments at each `load()` call.

## Data

The `data/` folder is **not tracked in git**. Restore it before rendering.

- `data/cleandat.csv` — cleaned Study 1 analysis file (*N* = 501). Built from
  `data/apsa17.csv` by `scripts/Data cleaning script.R` (scale construction,
  reverse-coding, behavior dummies, public/private/composite indices).
- `data/apsa17.csv` — raw survey export from Survey Sampling Inc.
- `data/*network_data_for_replication.RData` — saved `bootnet` nonparametric
  bootstrap objects.

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
