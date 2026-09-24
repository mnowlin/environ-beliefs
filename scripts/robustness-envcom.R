## robustness-envcom.R
## Study 2 robustness: is envcom's lead driven by its intention-like items?
##
## The main envcom scale (scripts/_issp-scale-defs.R) mixes concern (v15),
## everyday salience (v36), willingness to pay / sacrifice (v26-v28), and
## "I do what is right even when it costs more" (v31). The last four read as
## behavioral intentions, which would sit next to behavior almost by
## construction. Two variants, pubpriv behavior mode only:
##
##   lean  -- envcom = v15 + v36 only; v26-v28, v31 dropped from the network.
##            Bootstrapped (BOOT_B resamples per country).
##   split -- lean envcom plus the dropped items as their own node, `willing`.
##            Point estimates only.
##
## Everything else (worldview, threat, nature, left_right, public/private,
## EBICglasso settings, Dijkstra paths) is identical to scripts/analysis-issp.R.
##
## Run:  Rscript scripts/robustness-envcom.R
## Outputs (git-ignored):
##   data/issp_robust_envcom_summary_<variant>.csv
##   data/issp_robust_envcom_paths_<variant>.csv
##   data/issp_spl_boot_lean.rds

library(bootnet)
library(qgraph)
library(parallel)
source("scripts/_issp-scale-defs.R")
source("scripts/_spl-bootstrap.R")

d <- read.csv("data/issp_environment_2020.csv")

BOOT_B <- 1000
NCORES <- max(1, min(8, detectCores() - 1))

willing_items <- c("v26", "v27", "v28", "v31")
map_lean <- issp_scale_map_4
map_lean$envcom <- setdiff(issp_scale_map_4$envcom, willing_items)   # v15, v36
map_split <- c(map_lean, list(willing = willing_items))

variants <- list(
  lean  = list(map = map_lean,  boot = TRUE),
  split = list(map = map_split, boot = FALSE))

iso <- c("36"="AU","40"="AT","156"="CN","158"="TW","191"="HR","208"="DK",
         "246"="FI","250"="FR","276"="DE","348"="HU","352"="IS","356"="IN",
         "380"="IT","392"="JP","410"="KR","440"="LT","554"="NZ","578"="NO",
         "608"="PH","643"="RU","703"="SK","705"="SI","710"="ZA","724"="ES",
         "752"="SE","756"="CH","764"="TH","840"="US")
countries <- sort(unique(d$country))

yn        <- function(x) ifelse(x == 1, 1L, ifelse(x == 2, 0L, NA_integer_))
freq_dich <- function(x) ifelse(is.na(x), NA_integer_, as.integer(x %in% 1:2))
beh_nodes <- c("public", "private")

build_nodes <- function(s, map) {
  b <- make_issp_scales(s, map)
  lr <- s$PARTY_LR; lr[!lr %in% 1:5] <- NA
  b$left_right <- lr
  b$public  <- rowSums(cbind(yn(s$v54), yn(s$v55), yn(s$v56), yn(s$v57)), na.rm = TRUE)
  b$private <- rowSums(cbind(freq_dich(s$v52), freq_dich(s$v53)), na.rm = TRUE)
  b
}

keep_nodes <- function(nodes, min_prop = 0.5) vapply(nodes, function(col) {
  v <- stats::sd(col, na.rm = TRUE)
  mean(!is.na(col)) >= min_prop && is.finite(v) && v > 0
}, logical(1))

## Cronbach's alpha of the lean envcom (2 items) in the pooled data
o <- orient_issp(d)
a2 <- function(x) { x <- stats::na.omit(x); k <- ncol(x)
  k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x))) }
cat(sprintf("Pooled alpha: lean envcom (v15, v36) = %.2f; willing (v26-v28, v31) = %.2f\n",
            a2(o[map_lean$envcom]), a2(o[willing_items])))

run_variant <- function(vname) {
  v <- variants[[vname]]
  belief_nodes <- c(names(v$map), "left_right")
  boot_file <- sprintf("data/issp_spl_boot_%s.rds", vname)
  boots <- if (v$boot && file.exists(boot_file)) readRDS(boot_file) else list()

  paths_all <- list()
  for (cc in countries) {
    lab <- iso[as.character(cc)]
    nd  <- build_nodes(d[d$country == cc, ], v$map)[, c(belief_nodes, beh_nodes)]
    nd  <- nd[, keep_nodes(nd), drop = FALSE]
    net <- suppressWarnings(estimateNetwork(
      nd, default = "EBICglasso", corMethod = "cor_auto", tuning = 0.5,
      missing = "pairwise", corArgs = list(forcePD = TRUE)))
    sp  <- qgraph::centrality(net$graph)$ShortestPathLengths
    bel <- intersect(belief_nodes, names(nd))
    grd <- expand.grid(belief = bel, behavior = beh_nodes, stringsAsFactors = FALSE)
    grd$country <- lab
    grd$spl  <- mapply(function(b, y) sp[b, y], grd$belief, grd$behavior)
    grd$edge <- mapply(function(b, y) net$graph[b, y], grd$belief, grd$behavior)
    paths_all[[lab]] <- grd

    if (v$boot && is.null(boots[[lab]])) {
      boots[[lab]] <- tryCatch(
        boot_spl(nd, bel, beh_nodes, B = BOOT_B, seed = 1287, ncores = NCORES),
        error = function(e) NULL)
      saveRDS(boots, boot_file)
    }
    message(sprintf("[%s] %s done", vname, lab))
  }

  paths <- do.call(rbind, paths_all); rownames(paths) <- NULL
  summ <- aggregate(spl ~ country + belief, paths, function(z) mean(z[is.finite(z)]))
  names(summ)[3] <- "mean_spl"
  summ$p_closest <- mapply(function(cc, b) {
    cf <- boots[[cc]]$closest_freq
    if (!is.null(cf) && b %in% names(cf)) as.numeric(cf[b]) else NA_real_
  }, summ$country, summ$belief)
  summ$rank <- ave(summ$mean_spl, summ$country,
                   FUN = function(z) rank(z, ties.method = "min"))
  summ <- summ[order(summ$country, summ$rank), ]

  write.csv(paths, sprintf("data/issp_robust_envcom_paths_%s.csv", vname), row.names = FALSE)
  write.csv(summ,  sprintf("data/issp_robust_envcom_summary_%s.csv", vname), row.names = FALSE)

  cat(sprintf("\n########## variant = %s ##########\n", vname))
  top <- summ[summ$rank == 1, ]
  cat("Closest belief, by country:\n"); print(top, row.names = FALSE, digits = 3)
  cat("\nCount of countries where each belief is closest:\n")
  print(sort(table(top$belief), decreasing = TRUE))
  if (v$boot) cat(sprintf("Rank-1 belief bootstrap-supported (> .5) in %d of %d\n",
                          sum(top$p_closest > .5, na.rm = TRUE), length(countries)))
  cat("\nMean rank across countries:\n")
  mr <- aggregate(rank ~ belief, summ, mean); print(mr[order(mr$rank), ], row.names = FALSE, digits = 3)
  invisible(summ)
}

robust_results <- lapply(c("split", "lean"), run_variant)
