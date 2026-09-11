## analysis-issp-scales.R
## Study 2: build NEP/CNS-style belief SCALES for the ISSP 2020 data.
##
## Starting item pool = the "Recommended ISSP node set" in
## data/issp-2017-crosswalk.md section 7 (the belief/attitude items). EGA
## community detection is run over the pool and over sub-pools to see which
## grouping fits best (Total Entropy Fit Index, TEFI: lower = better), then
## scale scores are built from the chosen communities, oriented so that
## higher = more pro-environmental (mirroring scripts/analysis.R for Study 1).
##
## Run:  Rscript scripts/analysis-issp-scales.R
## Outputs (data/ git-ignored):
##   data/issp_ega_boot.RData             bootEGA cache (structure stability)
##   data/issp_scale_scores_pooled.csv    respondent x scale score (pooled)
##   data/issp-scales.md                  is written by hand, not here

library(EGAnet)
source("scripts/_issp-scale-defs.R")   # issp_reverse, orient_issp, issp_scale_map_*, make_issp_scales

d <- read.csv("data/issp_environment_2020.csv")
d$PARTY_LR[!d$PARTY_LR %in% 1:5] <- NA   # drop "other" (6) and "invalid" (96)

## ---------------------------------------------------------------------------
## Candidate belief/attitude item pool (crosswalk section 7)
##   v15         concern
##   v17         climate-change attribution (1-4, not 1-5)
##   v20-v25     Q10 environment / economy / science  (agree battery)
##   v26-v29     Q11 willingness to pay / sacrifice
##   v30-v36     Q12 efficacy / commitment / skepticism / proximity
##   v37-v43     Q13 perceived danger of 7 hazards
##   v46 v47     nature enjoyment / nature-leisure frequency
## PARTY_LR (left-right) is kept as a single-item ideology node, not scaled.
## ---------------------------------------------------------------------------
pool <- c("v15", "v17",
          paste0("v", 20:25), paste0("v", 26:29), paste0("v", 30:36),
          paste0("v", 37:43), "v46", "v47")

## a-priori (theoretical) grouping = the crosswalk batteries
apriori_struct <- c(
  v15 = 1,
  v17 = 2, v20 = 2, v21 = 2, v22 = 2, v23 = 2, v24 = 2, v25 = 2,
  v26 = 3, v27 = 3, v28 = 3, v29 = 3,
  v30 = 4, v31 = 4, v32 = 4, v33 = 4, v34 = 4, v35 = 4, v36 = 4,
  v37 = 5, v38 = 5, v39 = 5, v40 = 5, v41 = 5, v42 = 5, v43 = 5,
  v46 = 6, v47 = 6)

## Item orientation (issp_reverse / orient_issp) is defined in
## scripts/_issp-scale-defs.R: 6 - x on the items whose pro-environmental
## response is the low code, so every pool item runs higher = pro-environmental.

## ---------------------------------------------------------------------------
## EGA suite on the pooled sample
## ---------------------------------------------------------------------------
D <- orient_issp(d[pool])          # orientation does not change communities
set.seed(1287)

ega_wt  <- EGA(D, model = "glasso", algorithm = "walktrap", plot.EGA = FALSE)
ega_lv  <- EGA(D, model = "glasso", algorithm = "louvain",  plot.EGA = FALSE)
ega_fit <- EGA.fit(D, model = "glasso", algorithm = "louvain", plot.EGA = FALSE)

## per-battery: is each Q10/Q11/Q12/Q13 block one dimension?
batteries <- list(Q10 = paste0("v", 20:25), Q11 = paste0("v", 26:29),
                  Q12 = paste0("v", 30:36), Q13 = paste0("v", 37:43))
battery_ega <- lapply(batteries, function(v)
  EGA(D[v], model = "glasso", algorithm = "louvain", plot.EGA = FALSE))

## hierarchical EGA (lower-order dimensions + higher-order grouping)
hier_ega <- hierEGA(D, plot.hierEGA = FALSE)

## US-only replication of the pooled structure
DU <- orient_issp(d[d$country == 840, pool])
ega_us <- EGA(DU, model = "glasso", algorithm = "louvain", plot.EGA = FALSE)

## item-pool variants -- does dropping items improve fit?
variant_items <- list(
  full_pool      = pool,
  drop_v17       = setdiff(pool, "v17"),
  drop_ambiguous = setdiff(pool, c("v17", "v24", "v35")),
  drop_nature    = setdiff(pool, c("v46", "v47")))
variant_ega <- lapply(variant_items, function(v)
  EGA(D[v], model = "glasso", algorithm = "louvain", plot.EGA = FALSE))

## ---------------------------------------------------------------------------
## Structure comparison table (TEFI: lower = better fit)
## ---------------------------------------------------------------------------
tefi_of <- function(struct, data = D) tefi(data, structure = struct, verbose = FALSE)$VN.Entropy.Fit

structure_comparison <- rbind(
  data.frame(structure = "a-priori batteries (crosswalk s7)",
             n_dim = length(unique(apriori_struct[pool])),
             TEFI  = round(tefi_of(apriori_struct[pool]), 2)),
  data.frame(structure = "EGA walktrap, full pool",
             n_dim = ega_wt$n.dim, TEFI = round(ega_wt$TEFI, 2)),
  data.frame(structure = "EGA louvain, full pool  (chosen)",
             n_dim = ega_lv$n.dim, TEFI = round(ega_lv$TEFI, 2)),
  data.frame(structure = "EGA.fit optimized, full pool",
             n_dim = ega_fit$EGA$n.dim, TEFI = round(ega_fit$EGA$TEFI, 2)),
  data.frame(structure = "EGA louvain, drop v17",
             n_dim = variant_ega$drop_v17$n.dim, TEFI = round(variant_ega$drop_v17$TEFI, 2)),
  data.frame(structure = "EGA louvain, drop v17/v24/v35",
             n_dim = variant_ega$drop_ambiguous$n.dim, TEFI = round(variant_ega$drop_ambiguous$TEFI, 2)),
  data.frame(structure = "EGA louvain, drop nature (v46/v47)",
             n_dim = variant_ega$drop_nature$n.dim, TEFI = round(variant_ega$drop_nature$TEFI, 2)),
  data.frame(structure = "EGA louvain, US only",
             n_dim = ega_us$n.dim, TEFI = round(ega_us$TEFI, 2)))
rownames(structure_comparison) <- NULL

## ---------------------------------------------------------------------------
## bootEGA stability of the chosen (louvain, full pool) solution
## ---------------------------------------------------------------------------
issp_ega_boot_file <- "data/issp_ega_boot.RData"
if (file.exists(issp_ega_boot_file)) {
  load(issp_ega_boot_file)                 # -> issp_bootega
} else {
  set.seed(1287)
  issp_bootega <- bootEGA(D, iter = 500, model = "glasso", algorithm = "louvain",
                          type = "resampling", seed = 1287, verbose = FALSE,
                          plot.itemStability = FALSE)
  save(issp_bootega, file = issp_ega_boot_file)
}

ega_boot_summary <- list(
  factor_frequency      = issp_bootega$frequency,
  structural_consistency = round(issp_bootega$stability$dimension.stability$structural.consistency, 2),
  item_stability        = round(issp_bootega$stability$item.stability$item.stability$empirical.dimensions, 2))

## Final scale definitions (issp_scale_map_5 / issp_scale_map_4,
## make_issp_scales) are in scripts/_issp-scale-defs.R. The 4-scale set folds
## the 2-item v22/v25 community into worldview -- the same wording split kept
## as one dimension for the Study 1 NEP scale.
issp_scales <- make_issp_scales(d, issp_scale_map_4)

## reliability of each scale (pooled)
issp_scale_alpha <- sapply(issp_scale_map_4, function(items) {
  a <- try(psych::alpha(orient_issp(d[items]), warnings = FALSE)$total$raw_alpha, silent = TRUE)
  if (inherits(a, "try-error")) NA_real_ else round(a, 2)
})

## correlations among the scales and with the six behavior items
## (behaviors recoded: frequencies reversed so higher = more often; yes/no -> 1/0)
beh <- d[c("v52", "v53", "v54", "v55", "v56", "v57")]
beh$v52 <- 5 - beh$v52; beh$v53 <- 5 - beh$v53
for (v in c("v54", "v55", "v56", "v57"))
  beh[[v]] <- ifelse(beh[[v]] == 1, 1L, ifelse(beh[[v]] == 2, 0L, NA_integer_))
names(beh) <- c("recycle", "avoid_buy", "group_member", "petition", "donate", "protest")

issp_scale_cor <- round(cor(cbind(issp_scales, PARTY_LR = d$PARTY_LR, beh),
                            use = "pairwise.complete.obs"), 2)

write.csv(data.frame(issp_scales, PARTY_LR = d$PARTY_LR),
          "data/issp_scale_scores_pooled.csv", row.names = FALSE)

## EGA check on the six behavior items -- does the public/private split hold?
set.seed(1287)
ega_behavior <- EGA(beh, model = "glasso", algorithm = "louvain", plot.EGA = FALSE)
behavior_communities <- split(names(ega_behavior$wc), ega_behavior$wc)

## item -> scale table for the chosen 5-community EGA solution
scale_item_table <- data.frame(
  item      = names(ega_lv$wc),
  community = unname(ega_lv$wc),
  row.names = NULL)

## Bundle the display objects for the supplemental-materials qmd.
saveRDS(list(
  structure_comparison = structure_comparison,
  scale_ega_dims       = ega_lv$n.dim,
  ega_communities      = split(names(ega_lv$wc), ega_lv$wc),
  scale_item_table     = scale_item_table,
  battery_dims         = sapply(battery_ega, function(e) e$n.dim),
  ega_boot_summary     = ega_boot_summary,
  scale_map_4          = issp_scale_map_4,
  scale_alpha          = issp_scale_alpha,
  scale_cor            = issp_scale_cor,
  behavior_ega_dims    = ega_behavior$n.dim,
  behavior_ega_tefi    = round(ega_behavior$TEFI, 2),
  behavior_communities = behavior_communities,
  n_respondents        = nrow(d),
  n_countries          = length(unique(d$country))
), "data/issp_scale_dev.rds")

## ---------------------------------------------------------------------------
## Console report
## ---------------------------------------------------------------------------
cat("\n=== Structure comparison (TEFI: lower = better fit) ===\n")
print(structure_comparison, row.names = FALSE)

cat("\n=== Chosen: EGA louvain, full pool -- 5 communities ===\n")
print(split(names(ega_lv$wc), ega_lv$wc))

cat("\n=== Per-battery EGA (dims) ===\n")
for (nm in names(battery_ega))
  cat(sprintf("  %s: %d dims, TEFI %.2f\n", nm, battery_ega[[nm]]$n.dim, battery_ega[[nm]]$TEFI))

cat("\n=== bootEGA (500 resamples) ===\n")
print(ega_boot_summary$factor_frequency)
cat("structural consistency by community:\n"); print(ega_boot_summary$structural_consistency)

cat("\n=== Final scales (4-scale set; v22/v25 folded into worldview) ===\n")
for (nm in names(issp_scale_map_4))
  cat(sprintf("  %-10s (alpha %.2f): %s\n", nm, issp_scale_alpha[nm],
              paste(issp_scale_map_4[[nm]], collapse = ", ")))

cat("\n=== Scale x scale / scale x behavior correlations ===\n")
print(issp_scale_cor)

cat("\n=== EGA on the 6 behavior items ===\n")
cat("communities:", ega_behavior$n.dim, " TEFI:", round(ega_behavior$TEFI, 2), "\n")
print(behavior_communities)

cat("\nWrote data/issp_scale_scores_pooled.csv, data/issp_ega_boot.RData,",
    "data/issp_scale_dev.rds\n")
