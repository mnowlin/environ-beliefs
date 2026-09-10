## analysis.R
## Environmental Belief System Networks and Pro-Environmental Behavior
##
## Analysis code for the manuscript. Sourced (silently) at the top of
## environ-beliefs.qmd; tables/figures are built in code chunks in the .qmd
## that consume the objects created here, plus some inline R.
##
## Study 1: US data collected in July 2017 (N = 501), Survey Sampling Inc.
##   Data file: data/cleandat.csv (built by "scripts/Data cleaning script.R"
##   from data/apsa17.csv).
## Study 2: ISSP international data collected 2020 -- NOT YET INCORPORATED.
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

## ---------------------------------------------------------------------------
## Data
## ---------------------------------------------------------------------------
CCdata <- read.csv("data/cleandat.csv")

## ---------------------------------------------------------------------------
## Scale reliabilities (Cronbach's alpha) -- reported in "Data and Measures"
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

ccciA <- psy::cronbach(data.frame(
  CCdata$cc_ci_1, CCdata$cc_ci_2, CCdata$cc_ci_3, CCdata$cc_ci_4, CCdata$cc_ci_5,
  CCdata$cc_ci_6, CCdata$cc_ci_7, CCdata$cc_ci_8, CCdata$cc_ci_9, CCdata$cc_ci_11,
  CCdata$cc_ci_12, CCdata$cc_ci_13, CCdata$cc_ci_14, CCdata$cc_ci_15,
  CCdata$cc_ci_16, CCdata$cc_ci_17))

ccehA <- psy::cronbach(data.frame(
  CCdata$cc_eh_1, CCdata$cc_eh_2, CCdata$cc_eh_3, CCdata$cc_eh_4, CCdata$cc_eh_5,
  CCdata$cc_eh_6, CCdata$cc_eh_7, CCdata$cc_eh_8, CCdata$cc_eh_9, CCdata$cc_eh_10,
  CCdata$cc_eh_11, CCdata$cc_eh_12, CCdata$cc_eh_13, CCdata$cc_eh_14))

## ---------------------------------------------------------------------------
## Helper: build a tidy centrality data frame from a bootnet nonparametric
## bootstrap object, with a readable node label column.
## ---------------------------------------------------------------------------
centrality_frame <- function(boot_obj, labels) {
  stat <- summary(boot_obj)
  cent <- stat %>%
    dplyr::filter(type != "edge") %>%
    dplyr::select(type, id, mean, CIlower, CIupper)
  cent$labels <- rep(labels, length(unique(cent$type)))
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
## RESULTS 1: Environmental Belief System Network (beliefs only)
## ===========================================================================
envNetVars <- c("Ideology",
                "environmentalist", "enviro.move",
                "cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                "cns8","cns9","cns10","cns11","cns12_r","cns13","cns14_r",
                "nep1","nep2_r","nep3","nep4_r","nep5","nep6_r","nep7","nep8_r",
                "nep9","nep10_r","nep11","nep12_r","nep13","nep14_r","nep15")
envNetData <- CCdata[envNetVars]

envNetNetwork <- estimateNetwork(envNetData,
                                 default = "EBICglasso",
                                 corMethod = "cor_auto",
                                 tuning = 0.5)

## Grouping vector for the qgraph plot (see fig-envNetwork chunk in the .qmd)
envNetGroups <- factor(
  c(rep("Ideology", 1), rep("ENV", 2), rep("CNS", 14), rep("NEP", 15)),
  levels = c("Ideology", "ENV", "CNS", "NEP"))

## --- Centrality (nonparametric bootstrap, 1000 reps) ------------------------
## The bootstrap is expensive; it is pre-computed and stored. To regenerate:
##   set.seed(1287)
##   net_boot <- bootnet(envNetNetwork, nBoots = 1000, default = "EBICglasso",
##                       statistics = c("betweenness","closeness","strength","edge"),
##                       type = "nonparametric", nCores = 1)
##   save(net_boot, file = "data/ENVnetwork_data_for_replication.RData")
load("data/ENVnetwork_data_for_replication.RData")   # -> net_boot
env_boot <- net_boot
rm(net_boot)

## node ids come back in alphabetical order from bootnet::summary
env_labels <- c("Ideology","cns1","cns10","cns11","cns12_r","cns13",
                "cns14_r","cns2","cns3","cns4_r","cns5","cns6",
                "cns7","cns8","cns9","enviro.move","environmentalist",
                "nep1","nep10_r","nep11","nep12_r","nep13","nep14_r",
                "nep15","nep2_r","nep3","nep4_r","nep5","nep6_r",
                "nep7","nep8_r","nep9")

env_cent <- centrality_frame(env_boot, env_labels)

env_str_cent   <- dplyr::filter(env_cent, type == "strength")
env_close_cent <- dplyr::filter(env_cent, type == "closeness")
env_betw_cent  <- dplyr::filter(env_cent, type == "betweenness")

env_str_centP   <- centrality_panel(env_str_cent,   "Strength")
env_close_centP <- centrality_panel(env_close_cent, "Closeness")
env_betw_centP  <- centrality_panel(env_betw_cent,  "Betweenness") + xlab("Beliefs")

env_centralPlots <- egg::ggarrange(env_betw_centP, env_close_centP, env_str_centP,
                                   ncol = 3, nrow = 1)
ggsave("output/ENVcentralPlots.png", env_centralPlots, width = 10, height = 4)

## Ordered (most to least central) -- convenience for the write-up
env_betw_centO  <- dplyr::arrange(env_betw_cent,  dplyr::desc(mean))
env_close_centO <- dplyr::arrange(env_close_cent, dplyr::desc(mean))
env_str_centO   <- dplyr::arrange(env_str_cent,   dplyr::desc(mean))

## --- Centrality by belief type (CNS vs NEP): are the groups different? -----
env_cent$itemtype <- dplyr::case_when(
  grepl("^cns", env_cent$labels)                     ~ "CNS",
  grepl("^nep", env_cent$labels)                     ~ "NEP",
  env_cent$labels == "Ideology"                      ~ "Ideology",
  env_cent$labels %in% c("enviro.move", "environmentalist") ~ "ENV",
  TRUE                                               ~ NA_character_)

env_cent$measure <- factor(env_cent$type,
                           levels = c("betweenness", "closeness", "strength"),
                           labels = c("Betweenness", "Closeness", "Strength"))
env_cent$itemtype <- factor(env_cent$itemtype,
                            levels = c("NEP", "CNS", "Ideology", "ENV"))

env_centCOMP <- subset(env_cent, itemtype == "CNS" | itemtype == "NEP")

## t-tests: CNS vs NEP mean centrality (differences are not significant)
btwCOMP.t <- t.test(mean ~ itemtype, data = subset(env_centCOMP, measure == "Betweenness"))
clsCOMP.t <- t.test(mean ~ itemtype, data = subset(env_centCOMP, measure == "Closeness"))
strCOMP.t <- t.test(mean ~ itemtype, data = subset(env_centCOMP, measure == "Strength"))

## helpers for the by-type crossbar plot
ci <- function(x) (sd(x) / sqrt(length(x)) * qt(0.975, df = length(x) - 1))
data_summary <- function(x) {
  m <- mean(x)
  c(y = m, ymin = m - ci(x), ymax = m + ci(x))
}

centP <- ggplot(env_cent, aes(x = factor(itemtype), y = mean)) +
  geom_point(size = 2, position = position_jitter(width = .05, height = 0), alpha = .5) +
  facet_wrap(~measure, ncol = 3, scales = "free_y") +
  stat_summary(fun.data = data_summary, geom = "crossbar",
               linewidth = .5, width = .3, color = "black") +
  ylab("Centrality") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"),
        plot.caption = element_text(face = "italic"),
        axis.title.x = element_blank())

ggsave("output/centP.png", centP, width = 10, height = 4)

## ===========================================================================
## RESULTS 2: Environmental Belief System Network with Behavior
## ===========================================================================
envBNetVars <- c(envNetVars, "public", "private")
envBNetData <- CCdata[envBNetVars]

envBNetNetwork <- estimateNetwork(envBNetData,
                                  default = "EBICglasso",
                                  corMethod = "cor_auto",
                                  tuning = 0.5)

## partial correlations of each belief node with the two behavior nodes
envB_optnet <- envBNetNetwork$results$optnet
pubCor  <- envB_optnet[1:32, 33]   # public-behavior edges
privCor <- envB_optnet[1:32, 34]   # private-behavior edges

envBNetGroups <- factor(
  c(rep("Ideology", 1), rep("ENV", 2), rep("CNS", 14), rep("NEP", 15), rep("Behavior", 2)),
  levels = c("Ideology", "ENV", "CNS", "NEP", "Behavior"))

## --- Centrality (nonparametric bootstrap, 1000 reps) ----------------------
## To regenerate:
##   set.seed(1287)
##   net_boot <- bootnet(envBNetNetwork, nBoots = 1000, default = "EBICglasso",
##                       statistics = c("betweenness","closeness","strength","edge"),
##                       type = "nonparametric", nCores = 1)
##   save(net_boot, file = "data/ENVBnetwork_data_for_replication.RData")
load("data/ENVBnetwork_data_for_replication.RData")  # -> net_boot
envB_boot <- net_boot
rm(net_boot)

envB_labels <- c(env_labels, "private", "public")

envB_cent <- centrality_frame(envB_boot, envB_labels)

envB_str_cent   <- dplyr::filter(envB_cent, type == "strength")
envB_close_cent <- dplyr::filter(envB_cent, type == "closeness")
envB_betw_cent  <- dplyr::filter(envB_cent, type == "betweenness")

envB_str_centP   <- centrality_panel(envB_str_cent,   "Strength")
envB_close_centP <- centrality_panel(envB_close_cent, "Closeness")
envB_betw_centP  <- centrality_panel(envB_betw_cent,  "Betweenness") + xlab("Beliefs")

envB_centralPlots <- egg::ggarrange(envB_betw_centP, envB_close_centP, envB_str_centP,
                                    ncol = 3, nrow = 1)
ggsave("output/ENVBcentralPlots.png", envB_centralPlots, width = 10, height = 4)

envB_betw_centO  <- dplyr::arrange(envB_betw_cent,  dplyr::desc(mean))
envB_close_centO <- dplyr::arrange(envB_close_cent, dplyr::desc(mean))
envB_str_centO   <- dplyr::arrange(envB_str_cent,   dplyr::desc(mean))
