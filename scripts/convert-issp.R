## convert-issp.R
## One-off: convert the ISSP 2020 Environment SPSS file (ZA7650, v2-0-0) to CSV
## for Study 2, and write a small variable -> question-label codebook.
##
## Source .sav lives outside the repo (raw archive download); the CSV it
## produces lands in data/ (git-ignored, like the rest of data/).
##
## Run:  Rscript scripts/convert-issp.R

library(haven)
library(readr)

src <- "/Users/matthewnowlin/Library/CloudStorage/OneDrive-UTArlington/01-RESEARCH/03-data/ISSP-environment2020/ZA7650_v2-0-0.sav"

d <- read_sav(src)

## variable -> question label map (before we strip attributes)
codebook <- data.frame(
  variable = names(d),
  label    = vapply(d, function(x) {
    l <- attr(x, "label", exact = TRUE)
    if (is.null(l)) NA_character_ else as.character(l)
  }, character(1)),
  row.names = NULL
)

## Faithful numeric export: keep the ISSP codes as-is (including the negative
## missing codes -9 no answer, -8 can't choose/DK, -7 refused, -4 NAP,
## -1 not available). Recode those to NA at analysis time, not here.
d_num <- zap_labels(zap_missing(d))

write_csv(d_num, "data/issp_environment_2020.csv")
write_csv(codebook, "data/issp_environment_2020_codebook.csv")

cat(sprintf("Wrote data/issp_environment_2020.csv  (%d rows x %d cols)\n",
            nrow(d_num), ncol(d_num)))
cat(sprintf("Wrote data/issp_environment_2020_codebook.csv  (%d variables)\n",
            nrow(codebook)))
