## _issp-scale-defs.R
## Shared definitions for the Study 2 (ISSP 2020) belief scales.
## Derivation and fit comparison: scripts/analysis-issp-scales.R
## Write-up: data/issp-scales.md
##
## sourced by analysis-issp-scales.R and analysis-issp.R

## Items whose pro-environmental response is the LOW code -> flip with 6 - x
## so that every scale item runs HIGHER = more pro-environmental.
issp_reverse <- paste0("v", c(22, 25, 26, 27, 28, 31, 36,
                              37, 38, 39, 40, 41, 42, 43, 47))

orient_issp <- function(df) {
  x <- df
  for (v in intersect(issp_reverse, names(x))) x[[v]] <- 6 - x[[v]]
  x
}

## EGA (Louvain, pooled) communities, as-is: 5 scales
issp_scale_map_5 <- list(
  envcom    = c("v15", "v26", "v27", "v28", "v31", "v36"),
  worldview = c("v17", "v20", "v21", "v23", "v24", "v29", "v30", "v32", "v33", "v34", "v35"),
  limits    = c("v22", "v25"),
  threat    = paste0("v", 37:43),
  nature    = c("v46", "v47"))

## Recommended: fold the 2-item v22/v25 community into worldview (they are the
## pro-env-keyed NEP-type items -- the same wording split kept as one dimension
## for the Study 1 NEP scale). 4 scales.
issp_scale_map_4 <- issp_scale_map_5
issp_scale_map_4$worldview <- c(issp_scale_map_5$worldview, "v22", "v25")
issp_scale_map_4$limits <- NULL

## Unit-weighted item means of the oriented items (higher = pro-environmental).
## A respondent with some items missing is scored from the rest; all-missing -> NA.
make_issp_scales <- function(df, map = issp_scale_map_4) {
  o <- orient_issp(df)
  out <- lapply(map, function(items) {
    m <- rowMeans(o[intersect(items, names(o))], na.rm = TRUE)
    m[is.nan(m)] <- NA_real_
    m
  })
  as.data.frame(out)
}
