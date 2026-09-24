## analysis-issp.R
## Study 2: per-country belief -> behavior network analysis, ISSP 2020 Environment.
##
## One EBICglasso network per country (28) plus a pooled reference. Belief nodes
## are the four EGA-derived SCALE scores (scripts/analysis-issp-scales.R;
## data/issp-scales.md) plus PARTY_LR as a single ideology node -- mirroring the
## Study 1 move to NEP/CNS scale nodes in scripts/analysis.R -- and two
## single-item economic-belief nodes, market (v3) and redistribute (v4).
##
## Behavior mode(s) -- set MODES below (outputs suffixed _items / _pubpriv):
##   pubpriv -- Study 1-style indices (the specification reported in the paper):
##                public  = group_member + petition + donate + protest   (0-4 count)
##                private = recycle + avoid_buy, each dichotomised to
##                          "always / often" = 1                          (0-2 count)
##   items   -- the six individual ISSP behavior items (v52-v57); an unreported
##                robustness variant. Add "items" to MODES to regenerate it.
##
## Method mirrors scripts/analysis.R: EBICglasso GGM via bootnet/qgraph
## (corMethod = "cor_auto", tuning = 0.5, forcePD), then Dijkstra shortest paths
## on 1/|edge weight| from each belief node to each behavior node
## (qgraph::centrality(...)$ShortestPathLengths).
##
## Run:  Rscript scripts/analysis-issp.R
## Outputs (data/ is git-ignored):
##   data/issp_belief_behavior_paths_<mode>.csv     long: country x belief x behavior x shortest path + edge
##   data/issp_belief_behavior_summary_<mode>.csv   country x belief: mean/min path, closest behavior, rank
##   data/issp_networks_by_country_<mode>.rds       list of fitted networks (28 + POOLED)
##   output/issp/issp_networks_<mode>.pdf           one network plot per country
##   data/issp_pooled_belief_network.rds            pooled network, belief nodes only

library(bootnet)
library(qgraph)
library(EGAnet)
library(parallel)
source("scripts/_issp-scale-defs.R")   # issp_scale_map_4, make_issp_scales, orient_issp
source("scripts/_spl-bootstrap.R")     # boot_spl, fmt_ci

d <- read.csv("data/issp_environment_2020.csv")

MODES  <- c("pubpriv")                   # add "items" for the six-item robustness variant
BOOT_B <- 1000                          # bootstrap resamples per country/mode
NCORES <- max(1, min(8, detectCores() - 1))   # >8 oversubscribes and thrashes here

## ---------------------------------------------------------------------------
## Node builders
## ---------------------------------------------------------------------------
belief_nodes <- c("envcom", "worldview", "threat", "nature", "left_right",
                  "market", "redistribute")

## market / redistribute: Q2a (v3) "Private enterprise is the best way to solve
## [COUNTRY]'s economic problems" and Q2b (v4) "It is the responsibility of the
## government to reduce the differences in income ...". Single-item nodes, not a
## scale (pooled r = -.10; -.47 to .17 across countries). Recoded 6 - x so
## higher = more agreement.
build_beliefs <- function(s) {
  b <- make_issp_scales(s, issp_scale_map_4)          # envcom worldview threat nature
  lr <- s$PARTY_LR; lr[!lr %in% 1:5] <- NA            # drop "other"(6)/"invalid"(96)
  b$left_right   <- lr
  b$market       <- 6 - s$v3
  b$redistribute <- 6 - s$v4
  b
}

yn        <- function(x) ifelse(x == 1, 1L, ifelse(x == 2, 0L, NA_integer_))  # yes=1/no=0
freq_more <- function(x) 5 - x                        # 1 always..4 never -> higher = more often
freq_dich <- function(x) ifelse(is.na(x), NA_integer_, as.integer(x %in% 1:2))  # always/often = 1

build_behaviors <- list(
  items = function(s) data.frame(
    recycle      = freq_more(s$v52),
    avoid_buy    = freq_more(s$v53),
    group_member = yn(s$v54),
    petition     = yn(s$v55),
    donate       = yn(s$v56),
    protest      = yn(s$v57)),
  pubpriv = function(s) data.frame(
    public  = rowSums(cbind(yn(s$v54), yn(s$v55), yn(s$v56), yn(s$v57)), na.rm = TRUE),
    private = rowSums(cbind(freq_dich(s$v52), freq_dich(s$v53)), na.rm = TRUE)))

behavior_nodesets <- list(
  items   = c("recycle", "avoid_buy", "group_member", "petition", "donate", "protest"),
  pubpriv = c("public", "private"))

## country ISO-3166 numeric -> alpha-2
iso <- c("36"="AU","40"="AT","156"="CN","158"="TW","191"="HR","208"="DK",
         "246"="FI","250"="FR","276"="DE","348"="HU","352"="IS","356"="IN",
         "380"="IT","392"="JP","410"="KR","440"="LT","554"="NZ","578"="NO",
         "608"="PH","643"="RU","703"="SK","705"="SI","710"="ZA","724"="ES",
         "752"="SE","756"="CH","764"="TH","840"="US")
countries <- sort(unique(d$country))

## ---------------------------------------------------------------------------
## Fit + shortest paths
## ---------------------------------------------------------------------------
## forcePD = TRUE: near-constant binary behaviours (e.g. protest ~1% in JP)
## make the pairwise polychoric matrix non-PD; cor_auto then projects to the
## nearest PD matrix.
keep_nodes <- function(nodes, min_prop = 0.5) {
  ok <- vapply(nodes, function(col) {
    v <- stats::sd(col, na.rm = TRUE)
    mean(!is.na(col)) >= min_prop && is.finite(v) && v > 0
  }, logical(1))
  ok
}

fit_one <- function(nodes) {
  ok <- keep_nodes(nodes)
  dropped <- names(ok)[!ok]
  nodes <- nodes[, ok, drop = FALSE]
  net <- suppressWarnings(
    estimateNetwork(nodes, default = "EBICglasso", corMethod = "cor_auto",
                    tuning = 0.5, missing = "pairwise", corArgs = list(forcePD = TRUE)))
  list(net = net, dropped = dropped, n = nrow(nodes),
       n_complete = sum(stats::complete.cases(nodes)))
}

paths_one <- function(fit, country, beh_nodes) {
  g  <- fit$net$graph
  sp <- qgraph::centrality(g)$ShortestPathLengths
  bel <- intersect(belief_nodes, rownames(sp))
  beh <- intersect(beh_nodes,    rownames(sp))
  if (!length(bel) || !length(beh)) return(NULL)
  grd <- expand.grid(belief = bel, behavior = beh, stringsAsFactors = FALSE)
  grd$country <- country
  grd$spl  <- mapply(function(b, y) sp[b, y], grd$belief, grd$behavior)
  grd$edge <- mapply(function(b, y) g[b, y],  grd$belief, grd$behavior)
  grd[, c("country", "belief", "behavior", "spl", "edge")]
}

## ---------------------------------------------------------------------------
## Run one behavior mode end to end
## ---------------------------------------------------------------------------
run_mode <- function(mode) {
  bfn       <- build_behaviors[[mode]]
  beh_nodes <- behavior_nodesets[[mode]]
  all_nodes <- c(belief_nodes, beh_nodes)
  build_nodes <- function(s) cbind(build_beliefs(s), bfn(s))[, all_nodes]

  ## per-country bootstrap of belief -> behavior distances (cached per mode)
  boot_file <- sprintf("data/issp_spl_boot_%s.rds", mode)
  boots <- if (file.exists(boot_file)) readRDS(boot_file) else list()

  nets <- list(); paths_all <- list()
  for (cc in c(countries, NA)) {
    lab <- if (is.na(cc)) "POOLED" else iso[as.character(cc)]
    nd  <- if (is.na(cc)) build_nodes(d) else build_nodes(d[d$country == cc, ])
    nd  <- nd[, keep_nodes(nd), drop = FALSE]
    fit <- tryCatch(fit_one(nd), error = function(e) e)
    if (inherits(fit, "error")) { message(sprintf("[%s] %s: FAILED - %s", mode, lab, conditionMessage(fit))); next }
    nets[[lab]] <- fit
    pp <- paths_one(fit, lab, beh_nodes); if (!is.null(pp)) paths_all[[lab]] <- pp

    ## Bootstrap the per-country networks only. The POOLED network is a
    ## reference (44k respondents, no country structure); bootstrapping it is
    ## expensive and not used for inference, so it keeps its point estimate.
    if (!is.na(cc) && is.null(boots[[lab]])) {
      bb <- intersect(belief_nodes, names(nd)); yy <- intersect(beh_nodes, names(nd))
      boots[[lab]] <- tryCatch(
        boot_spl(nd, bb, yy, B = BOOT_B, seed = 1287, ncores = NCORES),
        error = function(e) NULL)
      saveRDS(boots, boot_file)                 # checkpoint after each country
    }
    message(sprintf("[%s] %s: n=%d (complete %d) nodes=%d dropped: %s",
                    mode, lab, fit$n, fit$n_complete, length(fit$net$labels),
                    if (length(fit$dropped)) paste(fit$dropped, collapse = ",") else "none"))
  }
  saveRDS(boots, boot_file)

  paths <- do.call(rbind, paths_all); rownames(paths) <- NULL

  summ <- do.call(rbind, lapply(split(paths, paste(paths$country, paths$belief)), function(s) {
    fin <- s$spl[is.finite(s$spl)]
    ctry <- s$country[1]; blf <- s$belief[1]
    bm <- boots[[ctry]]$belief_mean_ci
    bm <- if (!is.null(bm)) bm[bm$belief == blf, ] else NULL
    cf <- boots[[ctry]]$closest_freq
    data.frame(country = ctry, belief = blf,
               mean_spl = if (length(fin)) mean(fin) else Inf,
               mean_spl_lo = if (!is.null(bm) && nrow(bm)) bm$lo else NA_real_,
               mean_spl_hi = if (!is.null(bm) && nrow(bm)) bm$hi else NA_real_,
               p_closest = if (!is.null(cf) && blf %in% names(cf)) as.numeric(cf[blf]) else NA_real_,
               behaviors_reachable = length(fin),
               closest_behavior = if (length(fin))
                 s$behavior[which.min(replace(s$spl, !is.finite(s$spl), Inf))] else NA_character_)
  }))
  rownames(summ) <- NULL
  summ$rank <- ave(summ$mean_spl, summ$country,
                   FUN = function(z) rank(z, ties.method = "min", na.last = "keep"))
  summ <- summ[order(summ$country, summ$rank), ]

  write.csv(paths, sprintf("data/issp_belief_behavior_paths_%s.csv", mode), row.names = FALSE)
  write.csv(summ,  sprintf("data/issp_belief_behavior_summary_%s.csv", mode), row.names = FALSE)
  saveRDS(nets, sprintf("data/issp_networks_by_country_%s.rds", mode))

  dir.create("output/issp", showWarnings = FALSE, recursive = TRUE)
  pdf(sprintf("output/issp/issp_networks_%s.pdf", mode), width = 9, height = 7)
  for (lab in names(nets)) {
    g <- nets[[lab]]$net$graph
    grp <- ifelse(colnames(g) %in% beh_nodes, "Behavior", "Belief")
    qgraph(g, layout = "spring", labels = colnames(g), groups = grp,
           color = c(Belief = "#9ecae1", Behavior = "#fdae6b"),
           negDashed = TRUE, legend = TRUE, label.cex = 1.1, label.scale = FALSE,
           title = sprintf("%s  %s  (n = %d)", lab, mode, nets[[lab]]$n))
  }
  dev.off()

  cat(sprintf("\n#################### mode = %s ####################\n", mode))
  top <- summ[summ$rank == 1, c("country", "belief", "mean_spl", "p_closest")]
  cat("Belief closest to the behavior set, by country (p_closest = bootstrap support):\n")
  print(top[order(top$country), ], row.names = FALSE, digits = 3)
  cat(sprintf("\nRank-1 belief has bootstrap support > .5 in %d of %d countries; > .8 in %d.\n",
              sum(top$p_closest > .5, na.rm = TRUE), sum(top$country != "POOLED"),
              sum(top$p_closest > .8, na.rm = TRUE)))
  cat("\nHow often each belief ranks closest (28 countries):\n")
  print(sort(table(top$belief[top$country != "POOLED"]), decreasing = TRUE))
  cat("\nMean rank across countries (lower = closer to behavior):\n")
  mr <- aggregate(rank ~ belief, data = summ[summ$country != "POOLED", ], FUN = mean)
  print(mr[order(mr$rank), ], row.names = FALSE, digits = 3)
  cat("\nPOOLED belief -> behavior shortest paths:\n")
  pl <- paths[paths$country == "POOLED", c("belief", "behavior", "spl")]
  print(reshape(pl, idvar = "belief", timevar = "behavior", direction = "wide"),
        row.names = FALSE, digits = 3)

  invisible(list(paths = paths, summary = summ, nets = nets))
}

## ---------------------------------------------------------------------------
## EGA check on the six behavior items -- does the 2/4 public/private split hold?
## ---------------------------------------------------------------------------
beh_items <- build_behaviors$items(d)
set.seed(1287)
ega_behavior <- EGA(beh_items, model = "glasso", algorithm = "louvain", plot.EGA = FALSE)
cat("=== EGA on the 6 behavior items (pooled) ===\n")
cat("communities:", ega_behavior$n.dim, "  TEFI:", round(ega_behavior$TEFI, 2), "\n")
print(split(names(ega_behavior$wc), ega_behavior$wc))
cat("Expected public = group_member/petition/donate/protest; private = recycle/avoid_buy\n")

## ---------------------------------------------------------------------------
## Run the selected mode(s)
## ---------------------------------------------------------------------------
issp_results <- lapply(MODES, run_mode)
names(issp_results) <- MODES

## ---------------------------------------------------------------------------
## Pooled belief-only network (no behavior nodes), for the manuscript figure
## that sets it beside the pooled belief + behavior network. Same settings as
## the country networks; reference only (no country structure, no weights).
## ---------------------------------------------------------------------------
pooled_beliefs <- build_beliefs(d)[, belief_nodes]
pooled_belief_net <- fit_one(pooled_beliefs[, keep_nodes(pooled_beliefs), drop = FALSE])
saveRDS(pooled_belief_net, "data/issp_pooled_belief_network.rds")

cat(sprintf("\nWrote data/issp_belief_behavior_{paths,summary}_{%s}.csv etc.\n",
            paste(MODES, collapse = ",")))
