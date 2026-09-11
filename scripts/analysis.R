## analysis.R
## Environmental Belief System Networks and Pro-Environmental Behavior
##
## Analysis code for the manuscript. Sourced (silently) at the top of
## environ-beliefs.qmd; tables/figures are built in code chunks in the .qmd
## that consume the objects created here, plus some inline R.
##
## Study 1: US data collected in July 2017 (N = 1000), Survey Sampling Inc.
##   Data file: data/cleandat.csv (built by "scripts/Data cleaning script.R"
##   from data/apsa17.csv).
##   NOTE: the cultural-cognition batteries (cc_ci_*, cc_eh_*, Question Set 1)
##   were a split-ballot shown to only 501 of the 1000 respondents
##   (dumqset1shown); the other 499 saw an alternative item set. Cultural
##   cognition is therefore dropped from Study 1 so the belief-system network
##   uses the full N = 1000. NEP, CNS, environmentalist identity, ideology,
##   and the behavior items were asked of all 1000.
## Study 2: ISSP international data collected 2020 -- imported (data/, git-
##   ignored); see data/issp-2017-crosswalk.md. Study 2 network not yet built.
##
## Run standalone with:  Rscript scripts/analysis.R
## (paths are project-relative; _quarto.yaml sets execute-dir: project)

## ---------------------------------------------------------------------------
## Packages
## ---------------------------------------------------------------------------
library("tidyverse")
library("bootnet")
library("qgraph")
library("egg")
library("car")
library("ppcor")
library("modelsummary")
library("networktools")
library("NetworkComparisonTest")
library("EGAnet")

## ---------------------------------------------------------------------------
## Data
## ---------------------------------------------------------------------------
CCdata <- read.csv("data/cleandat.csv")
n_study1 <- nrow(CCdata)   # 1000

## ---------------------------------------------------------------------------
## Scale reliabilities (Cronbach's alpha) -- reported in "Data and Measures"
## Cultural-cognition alphas (cc_ci_*, cc_eh_*) are intentionally omitted:
## those items are the split-ballot half-sample and cultural cognition is not
## part of the Study 1 network.
## ---------------------------------------------------------------------------
proEVcompositeA <- psy::cronbach(data.frame(
  CCdata$product, CCdata$water, CCdata$buycott, CCdata$recycle, CCdata$energy,
  CCdata$stocks, CCdata$act.org, CCdata$cand, CCdata$money.org, CCdata$cont.off,
  CCdata$cont.bus, CCdata$petition, CCdata$meeting))
proEVprivateA <- psy::cronbach(data.frame(
  CCdata$product, CCdata$water, CCdata$buycott, CCdata$recycle, CCdata$energy))
proEVpublicA <- psy::cronbach(data.frame(
  CCdata$act.org, CCdata$cand, CCdata$money.org, CCdata$cont.off,
  CCdata$cont.bus, CCdata$petition, CCdata$meeting))

nepA <- psy::cronbach(data.frame(
  CCdata$nep1, CCdata$nep2_r, CCdata$nep3, CCdata$nep4_r, CCdata$nep5,
  CCdata$nep6_r, CCdata$nep7, CCdata$nep8_r, CCdata$nep9, CCdata$nep10_r,
  CCdata$nep11, CCdata$nep12_r, CCdata$nep13, CCdata$nep14_r, CCdata$nep15))

cnsA <- psy::cronbach(data.frame(
  CCdata$cns1, CCdata$cns2, CCdata$cns3, CCdata$cns4_r, CCdata$cns5, CCdata$cns6,
  CCdata$cns7, CCdata$cns8, CCdata$cns9, CCdata$cns10, CCdata$cns11,
  CCdata$cns12_r, CCdata$cns13, CCdata$cns14_r))

## ---------------------------------------------------------------------------
## Helper: build a tidy centrality data frame from a bootnet nonparametric
## bootstrap object, with a readable node label column.
## ---------------------------------------------------------------------------
centrality_frame <- function(boot_obj, labels = NULL) {
  stat <- summary(boot_obj)
  cent <- stat %>%
    dplyr::filter(type != "edge") %>%
    dplyr::select(type, id, mean, CIlower, CIupper)
  cent$labels <- if (is.null(labels)) as.character(cent$id) else
    rep(labels, length(unique(cent$type)))
  cent
}

centrality_panel <- function(cent, title) {
  ggplot(cent, aes(x = reorder(labels, mean), y = mean)) +
    geom_point() +
    geom_errorbar(aes(ymin = CIlower, ymax = CIupper),
                  stat = "identity", position = position_dodge(0.1), width = .1) +
    coord_flip() +
    xlab("") + ylab("") +
    ggtitle(title) +
    theme_minimal() +
    geom_vline(xintercept = 0, linetype = "dotted", alpha = .3) +
    theme(plot.title = element_text(face = "bold"),
          plot.caption = element_text(face = "italic"))
}

## ===========================================================================
## Scale scores: NEP and CNS as SINGLE dimensions, oriented so that
## HIGHER = more pro-environmental (and positively related to behavior).
##
## cleandat.csv stores every NEP/CNS item so that the ecological response is
## coded 1 (the survey coded "Strongly Agree" = 1; the *_r items were already
## flipped to align to that). So as stored, LOW = pro-environmental. Applying
## 6 - x to EVERY item flips this to HIGH = pro-environmental; the scale is
## then the item mean. (This reproduces the pre-built CCdata$NEP / CCdata$CNS,
## which the cleaning script also builds as 6 - item mean.)
## ===========================================================================
nep_items <- paste0("nep", c(1, "2_r", 3, "4_r", 5, "6_r", 7, "8_r", 9,
                             "10_r", 11, "12_r", 13, "14_r", 15))
cns_items <- paste0("cns", c(1:3, "4_r", 5:11, "12_r", 13, "14_r"))

CCdata[paste0(nep_items, "_pro")] <- 6 - CCdata[nep_items]
CCdata[paste0(cns_items, "_pro")] <- 6 - CCdata[cns_items]

CCdata$NEP <- rowMeans(CCdata[paste0(nep_items, "_pro")])  # ecological worldview
CCdata$CNS <- rowMeans(CCdata[paste0(cns_items, "_pro")])  # connectedness to nature

belief_nodes <- c("Ideology", "environmentalist", "enviro.move", "NEP", "CNS")

## ---------------------------------------------------------------------------
## Table 1: summary statistics + correlations for the Study 1 variables
## (composite/public/private behavior; NEP; CNS; ideology; identity).
## ---------------------------------------------------------------------------
tbl1_vars <- c("PEB", "public", "private", "NEP", "CNS",
               "Ideology", "environmentalist", "enviro.move")
tbl1_labs <- c("Pro-env. behavior (composite)", "Public behavior", "Private behavior",
               "NEP", "CNS", "Ideology (lib-con)", "Environmentalist identity",
               "Env. movement identity")
tbl1_dat <- CCdata[tbl1_vars]

tbl1_cor <- round(cor(tbl1_dat, use = "complete.obs"), 2)
tbl1_cor[upper.tri(tbl1_cor, diag = TRUE)] <- NA
dimnames(tbl1_cor) <- list(NULL, as.character(seq_along(tbl1_vars)))

descriptives_table <- data.frame(
  Variable = paste0(seq_along(tbl1_vars), ". ", tbl1_labs),
  M   = round(sapply(tbl1_dat, mean), 2),
  SD  = round(sapply(tbl1_dat, sd), 2),
  Min = round(sapply(tbl1_dat, min), 2),
  Max = round(sapply(tbl1_dat, max), 2),
  tbl1_cor,
  row.names = NULL, check.names = FALSE)

## ===========================================================================
## RESULTS 1: Environmental Belief System Network (beliefs only)
## ===========================================================================
envNetVars    <- belief_nodes
envNetData    <- CCdata[envNetVars]
envNetNetwork <- estimateNetwork(envNetData, default = "EBICglasso",
                                 corMethod = "cor_auto", tuning = 0.5)

## qgraph grouping + colors -- belief vs behavior, matching the Study 2
## country-network figure (blue beliefs, orange behavior nodes).
node_group <- function(v)
  factor(ifelse(v %in% c("public", "private"), "Behavior", "Belief"),
         levels = c("Belief", "Behavior"))
net_fig_cols  <- c("#9ecae1", "#fdae6b")   # Belief, Behavior
envNetGroups <- droplevels(node_group(envNetVars))

## --- Centrality: nonparametric bootstrap, 1000 reps -----------------------
## Cached (load-or-generate). Delete data/ENV*network_data_for_replication.RData
## to force a rebuild after changing the node set.
run_bootnet <- function(net) {
  set.seed(1287)
  bootnet(net, nBoots = 1000, default = "EBICglasso",
          statistics = c("betweenness", "closeness", "strength", "edge"),
          type = "nonparametric", nCores = 1)
}
env_boot_file <- "data/ENVnetwork_data_for_replication.RData"
if (file.exists(env_boot_file)) load(env_boot_file) else {
  net_boot <- run_bootnet(envNetNetwork); save(net_boot, file = env_boot_file)
}
env_boot <- net_boot; rm(net_boot)

env_cent <- centrality_frame(env_boot)   # node ids are readable, no relabel

env_str_cent   <- dplyr::filter(env_cent, type == "strength")
env_close_cent <- dplyr::filter(env_cent, type == "closeness")
env_betw_cent  <- dplyr::filter(env_cent, type == "betweenness")

env_str_centP   <- centrality_panel(env_str_cent,   "Strength")
env_close_centP <- centrality_panel(env_close_cent, "Closeness")
env_betw_centP  <- centrality_panel(env_betw_cent,  "Betweenness") + xlab("Belief")

env_centralPlots <- egg::ggarrange(env_betw_centP, env_close_centP, env_str_centP,
                                   ncol = 3, nrow = 1)
ggsave("output/ENVcentralPlots.png", env_centralPlots, width = 10, height = 4)

env_betw_centO  <- dplyr::arrange(env_betw_cent,  dplyr::desc(mean))
env_close_centO <- dplyr::arrange(env_close_cent, dplyr::desc(mean))
env_str_centO   <- dplyr::arrange(env_str_cent,   dplyr::desc(mean))

## ===========================================================================
## RESULTS 2: Environmental Belief System Network with Behavior
## ===========================================================================
envBNetVars    <- c(belief_nodes, "public", "private")
envBNetData    <- CCdata[envBNetVars]
envBNetNetwork <- estimateNetwork(envBNetData, default = "EBICglasso",
                                  corMethod = "cor_auto", tuning = 0.5)

envBNetGroups <- node_group(envBNetVars)

## partial correlations of each belief node with the two behavior nodes
envB_optnet <- envBNetNetwork$graph
pubCor  <- envB_optnet[belief_nodes, "public"]
privCor <- envB_optnet[belief_nodes, "private"]

envB_boot_file <- "data/ENVBnetwork_data_for_replication.RData"
if (file.exists(envB_boot_file)) load(envB_boot_file) else {
  net_boot <- run_bootnet(envBNetNetwork); save(net_boot, file = envB_boot_file)
}
envB_boot <- net_boot; rm(net_boot)

envB_cent <- centrality_frame(envB_boot)

envB_str_cent   <- dplyr::filter(envB_cent, type == "strength")
envB_close_cent <- dplyr::filter(envB_cent, type == "closeness")
envB_betw_cent  <- dplyr::filter(envB_cent, type == "betweenness")

envB_str_centP   <- centrality_panel(envB_str_cent,   "Strength")
envB_close_centP <- centrality_panel(envB_close_cent, "Closeness")
envB_betw_centP  <- centrality_panel(envB_betw_cent,  "Betweenness") + xlab("Node")

envB_centralPlots <- egg::ggarrange(envB_betw_centP, envB_close_centP, envB_str_centP,
                                    ncol = 3, nrow = 1)
ggsave("output/ENVBcentralPlots.png", envB_centralPlots, width = 10, height = 4)

envB_betw_centO  <- dplyr::arrange(envB_betw_cent,  dplyr::desc(mean))
envB_close_centO <- dplyr::arrange(envB_close_cent, dplyr::desc(mean))
envB_str_centO   <- dplyr::arrange(envB_str_cent,   dplyr::desc(mean))

## ===========================================================================
## RESULTS 3: shortest path from each belief to each behavior
## Dijkstra on distance = 1 / |edge weight| (Brandt et al. 2019), with
## nonparametric bootstrap percentile CIs (1000 resamples).
## ===========================================================================
source("scripts/_spl-bootstrap.R")
envB_spl <- qgraph::centrality(envBNetNetwork$graph)$ShortestPathLengths

envB_spl_boot_file <- "data/ENVB_spl_bootstrap.RData"
if (file.exists(envB_spl_boot_file)) {
  load(envB_spl_boot_file)                       # -> envB_spl_boot
} else {
  envB_spl_boot <- boot_spl(CCdata[envBNetVars], belief_nodes,
                            c("public", "private"), B = 1000, seed = 1287,
                            ncores = max(1, parallel::detectCores() - 1))
  save(envB_spl_boot, file = envB_spl_boot_file)
}
envB_spl_closest_freq <- envB_spl_boot$closest_freq   # P(belief is closest)

pc_pub  <- envB_spl_boot$pair_ci[envB_spl_boot$pair_ci$behavior == "public", ]
pc_priv <- envB_spl_boot$pair_ci[envB_spl_boot$pair_ci$behavior == "private", ]

belief_behavior_spl <- data.frame(
  belief       = belief_nodes,
  to_public    = envB_spl[belief_nodes, "public"],
  pub_lo       = pc_pub$lo[match(belief_nodes, pc_pub$belief)],
  pub_hi       = pc_pub$hi[match(belief_nodes, pc_pub$belief)],
  to_private   = envB_spl[belief_nodes, "private"],
  priv_lo      = pc_priv$lo[match(belief_nodes, pc_priv$belief)],
  priv_hi      = pc_priv$hi[match(belief_nodes, pc_priv$belief)],
  edge_public  = as.numeric(pubCor),
  edge_private = as.numeric(privCor),
  row.names = NULL)
belief_behavior_spl$mean_dist <- rowMeans(belief_behavior_spl[, c("to_public", "to_private")])
belief_behavior_spl <- belief_behavior_spl[order(belief_behavior_spl$mean_dist), ]
rownames(belief_behavior_spl) <- NULL

## display table for the manuscript: point estimate [95% CI] per behavior
belief_behavior_spl_display <- with(belief_behavior_spl, data.frame(
  Belief          = belief,
  `To public`     = fmt_ci(to_public,  pub_lo,  pub_hi),
  `To private`    = fmt_ci(to_private, priv_lo, priv_hi),
  `Mean distance` = round(mean_dist, 1),
  check.names = FALSE, row.names = NULL))

## ===========================================================================
## APPENDIX: dimensionality of the NEP and CNS scales (EGA / UVA)
## ---------------------------------------------------------------------------
## Checks whether NEP and CNS each behave as a coherent dimension before they
## are used (as item nodes, or as scale-score nodes) in the belief network.
##   * EGA  -- exploratory graph analysis: estimate a GGM over the items and
##             detect communities (Walktrap). Run per scale and jointly.
##   * bootEGA -- resampling stability of the community structure.
##   * UVA  -- unique variable analysis: flag locally redundant item pairs
##             (weighted topological overlap; default cut-off 0.25).
##   * net.scores -- network (EGA) dimension score, as an alternative to the
##             unit-weighted raw mean.
## ---------------------------------------------------------------------------
## nep_items / cns_items are defined above (scale-scores section).
## EGA is computed on the items as stored; 6 - x on every item does not change
## any correlation, so the community structure below is unaffected by
## orientation.

ega_seed <- 1287

set.seed(ega_seed)
ega_nep    <- EGA(CCdata[nep_items], model = "glasso", algorithm = "walktrap",
                  plot.EGA = FALSE)
ega_cns    <- EGA(CCdata[cns_items], model = "glasso", algorithm = "walktrap",
                  plot.EGA = FALSE)
ega_nepcns <- EGA(CCdata[c(nep_items, cns_items)], model = "glasso",
                  algorithm = "walktrap", plot.EGA = FALSE)

## Community assignments align with item KEYING (forward vs reverse-worded),
## not with substantive NEP/CNS content -- i.e. a wording/method factor. Tag
## each item so the appendix table can show this.
ega_comm <- data.frame(
  item      = c(nep_items, cns_items),
  scale     = c(rep("NEP", length(nep_items)), rep("CNS", length(cns_items))),
  keying    = ifelse(grepl("_r$", c(nep_items, cns_items)), "reverse", "forward"),
  community_scale = c(ega_nep$wc[nep_items], ega_cns$wc[cns_items]),
  community_joint = ega_nepcns$wc[c(nep_items, cns_items)],
  row.names = NULL
)

## UVA -- redundancy. Standard cut-off 0.25, plus 0.20 to surface near pairs.
set.seed(ega_seed)
uva_nep     <- UVA(CCdata[nep_items], cut.off = 0.25)
uva_cns     <- UVA(CCdata[cns_items], cut.off = 0.25)
uva_nep_20  <- UVA(CCdata[nep_items], cut.off = 0.20)
uva_cns_20  <- UVA(CCdata[cns_items], cut.off = 0.20)

uva_top <- function(u, scale, k = 5) {
  pw <- u$wto$pairwise
  pw <- pw[order(-pw$wto), ][seq_len(min(k, nrow(pw))), ]
  data.frame(scale = scale, item_i = pw$node_i, item_j = pw$node_j,
             wTO = round(pw$wto, 3), row.names = NULL)
}
uva_top_pairs <- rbind(uva_top(uva_nep_20, "NEP"), uva_top(uva_cns_20, "CNS"))
uva_redundant <- list(NEP = uva_nep$redundant, CNS = uva_cns$redundant)   # both NULL at 0.25

## bootEGA -- structural / item stability of the community solution.
## 500 resamples; cached because it is slow.
ega_boot_file <- "data/ega_boot_study1.RData"
if (file.exists(ega_boot_file)) {
  load(ega_boot_file)                       # -> bootega_nep, bootega_cns
} else {
  set.seed(ega_seed)
  bootega_nep <- bootEGA(CCdata[nep_items], iter = 500, model = "glasso",
                         type = "resampling", seed = ega_seed, verbose = FALSE,
                         plot.itemStability = FALSE)
  bootega_cns <- bootEGA(CCdata[cns_items], iter = 500, model = "glasso",
                         type = "resampling", seed = ega_seed, verbose = FALSE,
                         plot.itemStability = FALSE)
  save(bootega_nep, bootega_cns, file = ega_boot_file)
}

boot_dim_modal <- function(b) {
  f <- b$frequency
  k <- f[[1]][which.max(f[[2]])]
  sprintf("%d (%.0f%% of resamples)", k, 100 * max(f[[2]]))
}
item_stab <- function(b) b$stability$item.stability$item.stability$empirical.dimensions

ega_stability <- data.frame(
  scale = c("NEP", "CNS"),
  items = c(length(nep_items), length(cns_items)),
  alpha = round(c(nepA$alpha, cnsA$alpha), 2),
  ega_dim_empirical = c(ega_nep$n.dim, ega_cns$n.dim),
  bootega_median_dim = c(bootega_nep$summary.table$median.dim,
                         bootega_cns$summary.table$median.dim),
  bootega_modal_dim = c(boot_dim_modal(bootega_nep), boot_dim_modal(bootega_cns)),
  structural_consistency = c(
    paste(sprintf("%.2f", bootega_nep$stability$dimension.stability$structural.consistency), collapse = " / "),
    paste(sprintf("%.2f", bootega_cns$stability$dimension.stability$structural.consistency), collapse = " / ")),
  mean_item_stability = round(c(mean(item_stab(bootega_nep)), mean(item_stab(bootega_cns))), 2),
  row.names = NULL
)

## per-item stability, tagged by keying, for the appendix item table
ega_comm$item_stability <- c(item_stab(bootega_nep)[nep_items],
                             item_stab(bootega_cns)[cns_items])

## Dimension scores: single network (EGA) score per scale vs the raw mean.
## The multi-community EGA solution is a keying artifact, so each scale is
## scored as ONE dimension (wc forced to 1).
## NOTE cleandat.csv codes every NEP/CNS item so that a LOW value = more
## pro-environmental / more connected (the odd items are raw 1 = strongly
## agree, the *_r items are 6 - raw). The means below are reversed (6 - mean)
## so that HIGHER = more pro-environmental, matching the usual NEP/CNS
## orientation and CCdata$NEP / CCdata$CNS. The EGA network scores are
## sign-aligned to the reversed raw mean.
nep_one <- setNames(rep(1L, length(nep_items)), nep_items)
cns_one <- setNames(rep(1L, length(cns_items)), cns_items)
nep_rawmean <- 6 - rowMeans(CCdata[nep_items])
cns_rawmean <- 6 - rowMeans(CCdata[cns_items])

nep_ns_raw <- as.numeric(net.scores(CCdata[nep_items], A = ega_nep$network,
                                    wc = nep_one)$scores$std.scores[, 1])
cns_ns_raw <- as.numeric(net.scores(CCdata[cns_items], A = ega_cns$network,
                                    wc = cns_one)$scores$std.scores[, 1])
nep_netscore <- nep_ns_raw * sign(cor(nep_ns_raw, nep_rawmean))
cns_netscore <- cns_ns_raw * sign(cor(cns_ns_raw, cns_rawmean))

## UVA-reduced means (drop one item from each near-redundant NEP pair at 0.20:
## nep8_r~nep10_r and nep1~nep11 -> keep nep10_r, nep11; CNS: none)
nep_items_uva <- setdiff(nep_items, c("nep8_r", "nep1"))
nep_uvamean   <- 6 - rowMeans(CCdata[nep_items_uva])

ega_score_cor <- round(cor(
  data.frame(NEP_raw = nep_rawmean, NEP_EGA = nep_netscore, NEP_UVA = nep_uvamean,
             CNS_raw = cns_rawmean, CNS_EGA = cns_netscore,
             public = CCdata$public, private = CCdata$private)),
  3)

## EGA plots for the appendix figure (node color = detected community).
ega_plot_nep   <- plot(ega_nep)   + ggplot2::ggtitle("NEP (15 items)")
ega_plot_cns   <- plot(ega_cns)   + ggplot2::ggtitle("CNS (14 items)")
ega_plot_joint <- plot(ega_nepcns) + ggplot2::ggtitle("NEP + CNS jointly (29 items)")
