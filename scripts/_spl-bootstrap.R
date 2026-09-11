## _spl-bootstrap.R
## Nonparametric bootstrap of belief -> behavior shortest-path distances
## (Brandt et al. 2019 approach): resample respondents with replacement,
## re-estimate the EBICglasso network, recompute Dijkstra shortest paths on
## 1/|edge weight|, and take percentile CIs.
##
## sourced by scripts/analysis.R and scripts/analysis-issp.R

boot_spl <- function(data, belief_nodes, behavior_nodes, B = 2000, seed = 1287,
                     tuning = 0.5, ncores = 1) {
  data <- data[, c(belief_nodes, behavior_nodes), drop = FALSE]
  n    <- nrow(data)
  grid <- expand.grid(belief = belief_nodes, behavior = behavior_nodes,
                      stringsAsFactors = FALSE)
  key  <- paste(grid$belief, grid$behavior, sep = "->")

  one_draw <- function(b) {
    set.seed(seed + b)
    idx <- sample.int(n, n, replace = TRUE)
    net <- tryCatch(suppressWarnings(bootnet::estimateNetwork(
      data[idx, , drop = FALSE], default = "EBICglasso", corMethod = "cor_auto",
      tuning = tuning, missing = "pairwise", corArgs = list(forcePD = TRUE))),
      error = function(e) NULL)
    if (is.null(net)) return(setNames(rep(NA_real_, nrow(grid)), key))
    sp <- qgraph::centrality(net$graph)$ShortestPathLengths
    vapply(seq_len(nrow(grid)), function(i) {
      if (grid$belief[i] %in% rownames(sp) && grid$behavior[i] %in% colnames(sp))
        sp[grid$belief[i], grid$behavior[i]] else NA_real_
    }, numeric(1))
  }

  draws <- if (ncores > 1) {
    do.call(rbind, parallel::mclapply(seq_len(B), one_draw, mc.cores = ncores))
  } else {
    t(vapply(seq_len(B), one_draw, numeric(nrow(grid))))
  }
  colnames(draws) <- key

  ## per belief -> behavior pair
  pair_ci <- cbind(grid, t(apply(draws, 2, function(x) {
    x <- x[is.finite(x)]
    if (!length(x)) return(c(median = NA, lo = NA, hi = NA, prop_finite = 0))
    c(median = stats::median(x),
      lo = stats::quantile(x, .025, names = FALSE),
      hi = stats::quantile(x, .975, names = FALSE),
      prop_finite = length(x) / B)
  })))
  rownames(pair_ci) <- NULL

  ## per belief: mean distance over the behavior set, within each draw
  belief_means <- sapply(belief_nodes, function(b) {
    cols <- which(grid$belief == b)
    apply(draws[, cols, drop = FALSE], 1, function(r) {
      r <- r[is.finite(r)]; if (length(r)) mean(r) else NA_real_
    })
  })
  belief_mean_ci <- data.frame(
    belief = belief_nodes,
    t(apply(belief_means, 2, function(x) {
      x <- x[is.finite(x)]
      if (!length(x)) return(c(median = NA, lo = NA, hi = NA))
      c(median = stats::median(x),
        lo = stats::quantile(x, .025, names = FALSE),
        hi = stats::quantile(x, .975, names = FALSE))
    })), row.names = NULL)

  ## proportion of draws in which each belief is the closest to the behavior set
  closest <- apply(belief_means, 1, function(r)
    if (all(is.na(r))) NA_character_ else belief_nodes[which.min(r)])
  closest_freq <- prop.table(table(factor(closest, levels = belief_nodes)))

  list(draws = draws, pair_ci = pair_ci, belief_mean_ci = belief_mean_ci,
       closest_freq = closest_freq, B = B, n_ok = sum(!is.na(draws[, 1])))
}

## "d [lo, hi]" formatter for tables
fmt_ci <- function(est, lo, hi, digits = 1)
  ifelse(is.na(est), "--",
         sprintf(paste0("%.", digits, "f [%.", digits, "f, %.", digits, "f]"), est, lo, hi))
