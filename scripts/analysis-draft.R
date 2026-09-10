# DRAFT analysis 

## packages 
library("tidyverse")
library("bootnet")
library("qgraph")
library("ggplot2")
library("egg")
library("car")
library("ppcor")
library("modelsummary")
library("networktools")
library("NetworkComparisonTest")

## load data 
CCdata <- read.csv("data/cleandat.csv")
names(CCdata)

## networks
### cc-ci 
ciNetVars <- c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8",
                "cc_ci_9","cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17")
ciNetData <- CCdata[ciNetVars]

ciNetNetwork <- estimateNetwork(ciNetData, 
                                 default = "EBICglasso",
                                 corMethod = "cor_auto",
                                 tuning = 0.5)

plot(ciNetNetwork, layout = "spring", negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")


### cc-eh 
ehNetVars <- c("cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7",
               "cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14")
ehNetData <- CCdata[ehNetVars]

ehNetNetwork <- estimateNetwork(ehNetData, 
                                default = "EBICglasso",
                                corMethod = "cor_auto",
                                tuning = 0.5)

plot(ehNetNetwork, layout = "spring", negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")

### combine cc ci-eh 
ccNetVars <- c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8",
               "cc_ci_9","cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17",
               "cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7",
               "cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14")
ccNetData <- CCdata[ccNetVars]

ccNetNetwork <- estimateNetwork(ccNetData, 
                                default = "EBICglasso",
                                corMethod = "cor_auto",
                                tuning = 0.5)

groups <- factor(c(
  rep("INDIV", 11),
  rep("COMM", 5), 
  rep("HIER", 7),
  rep("EGAL", 7)
))

groups <- factor(as.character(groups), levels = c("INDIV","COMM","HIER","EGAL"))

plot(ccNetNetwork, layout = "spring", groups=groups, negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")


### cns 
cnsNetVars <- c("cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                "cns8","cns9","cns10","cns11","cns12_r","cns13","cns14_r")
cnsNetData <- CCdata[cnsNetVars]

cnsNetNetwork <- estimateNetwork(cnsNetData, 
                                    default = "EBICglasso",
                                    corMethod = "cor_auto",
                                    tuning = 0.5)

plot(cnsNetNetwork, layout = "spring", negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")

### nep
nepNetVars <- c("nep1","nep2_r","nep3","nep4_r","nep5","nep6_r","nep7","nep8_r",
                "nep9","nep10_r","nep11","nep12_r","nep13","nep14_r","nep15")
nepNetData <- CCdata[nepNetVars]

nepNetNetwork <- estimateNetwork(nepNetData, 
                                 default = "EBICglasso",
                                 corMethod = "cor_auto",
                                 tuning = 0.5)

plot(nepNetNetwork, layout = "spring", negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")

names(CCdata)
### combine cns + nep
envNetVars <- c("Ideology",
                "environmentalist", "enviro.move",
                "cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                "cns8","cns9","cns10","cns11","cns12_r","cns13","cns14_r",
                "nep1","nep2_r","nep3","nep4_r","nep5","nep6_r","nep7","nep8_r",
                "nep9","nep10_r","nep11","nep12_r","nep13","nep14_r","nep15"
                )
envNetData <- CCdata[envNetVars]

envNetNetwork <- estimateNetwork(envNetData, 
                                 default = "EBICglasso",
                                 corMethod = "cor_auto",
                                 tuning = 0.5)
groups <- factor(c(
  rep("Ideology", 1),
  rep("ENV", 2),
  rep("CNS", 14), 
  rep("NEP", 15)
))

groups <- factor(as.character(groups), levels = c("Ideology","ENV","CNS", "NEP"))


plot(envNetNetwork, layout = "spring", groups=groups, negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")

envBNetVars <- c("Ideology",
                "environmentalist", "enviro.move",
                "cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                "cns8","cns9","cns10","cns11","cns12_r","cns13","cns14_r",
                "nep1","nep2_r","nep3","nep4_r","nep5","nep6_r","nep7","nep8_r",
                "nep9","nep10_r","nep11","nep12_r","nep13","nep14_r","nep15",
                "public","private")
envBNetData <- CCdata[envBNetVars]

envBNetNetwork <- estimateNetwork(envBNetData, 
                                 default = "EBICglasso",
                                 corMethod = "cor_auto",
                                 tuning = 0.5)
groups <- factor(c(
  rep("Ideology", 1),
  rep("ENV", 2),
  rep("CNS", 14), 
  rep("NEP", 15),
  rep("Behavior", 2)
))

groups <- factor(as.character(groups), levels = c("Ideology","ENV","CNS", "NEP", "Behavior"))


plot(envBNetNetwork, layout = "spring", groups=groups, negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")


### network of combined scales with behavior
combineNetVars <- c("Ideology",
                    "environmentalist","enviro.move",
                    "CNS","NEP",
                    "public","private"
                    )
combineNetData <- CCdata[combineNetVars]

combineNetNetwork <- estimateNetwork(combineNetData, 
                                 default = "EBICglasso",
                                 corMethod = "cor_auto",
                                 tuning = 0.5)
groups <- factor(c(
  rep("Ideology", 1),
  rep("Environmental", 4),
  rep("Behavior", 2)
))

groups <- factor(as.character(groups), levels = c("Ideology","Environmental","Behavior"))


plot(combineNetNetwork, layout = "spring", groups=groups, negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")
combineNetNetwork$results$optnet

set.seed(1287) 
net_boot <- bootnet(envNetNetwork, nBoots = 1000,
                     default = "EBICglasso",
                     statistics = c("betweenness","closeness","strength","edge"),
                     type = "nonparametric", nCores = 1)

save(net_boot, file= paste0(getwd(),"/data/ENVnetwork_data_for_replication.RData"))

load(paste0(getwd(),"/data/ENVnetwork_data_for_replication.RData"))

summary(net_boot)


net_boot_whole <- net_boot$bootTable
# net_boot_strength <- net_boot_whole %>%
#  filter(type=="strength") %>%
#  filter(id == c("US \nrisk","GW \nworry"))

net_boot_stat<-summary(net_boot)
net_boot_stat_cent <- net_boot_stat %>%
  filter(type!="edge")

cent_stat <- net_boot_stat_cent %>%
  dplyr::select(type, id, mean, CIlower, CIupper)
cent_stat$id

labels2 <- c("Ideology","cns1","cns10","cns11","cns12_r","cns13",
             "cns14_r","cns2","cns3","cns4_r","cns5","cns6",
             "cns7","cns8","cns9","enviro.move","environmentalist",
             "nep1","nep10_r","nep11","nep12_r","nep13","nep14_r",
             "nep15","nep2_r","nep3","nep4_r","nep5","nep6_r",
             "nep7","nep8_r","nep9" )

cent_stat$labels <- rep(labels2, 3)

str_cent<- cent_stat %>%
  filter(type == "strength")

str_centP <- ggplot(data = str_cent, aes(x=reorder(labels, mean), y=mean)) + 
  geom_point() +
  geom_errorbar(aes(ymin=(CIlower), ymax=(CIupper)), stat = "identity", position=position_dodge(0.1), width=.1) +
  coord_flip() +
  xlab("") +
  ylab("") + 
  ggtitle("Strength") +
  theme_minimal() +
  geom_vline(xintercept = 0, linetype = "dotted", alpha = .3) +
  theme(plot.title = element_text(face = "bold"),
        plot.caption = element_text(face = "italic"))

close_cent<- cent_stat %>%
  filter(type == "closeness")

close_centP <- ggplot(data = close_cent, aes(x=reorder(labels, mean), y=mean)) + 
  geom_point() +
  geom_errorbar(aes(ymin=(CIlower), ymax=(CIupper)), stat = "identity", position=position_dodge(0.1), width=.1) +
  coord_flip() +
  xlab("") +
  ylab("") + 
  ggtitle("Closeness") +
  theme_minimal() +
  geom_vline(xintercept = 0, linetype = "dotted", alpha = .3) +
  theme(plot.title = element_text(face = "bold"),
        plot.caption = element_text(face = "italic"))

betw_cent <- cent_stat %>%
  filter(type == "betweenness")

betw_centP <- ggplot(data = betw_cent, aes(x=reorder(labels, mean), y=mean)) + 
  geom_point() +
  geom_errorbar(aes(ymin=(CIlower), ymax=(CIupper)), stat = "identity", position=position_dodge(0.1), width=.1) +
  coord_flip() +
  xlab("Beliefs") +
  ylab("") + 
  ggtitle("Betweenness") +
  theme_minimal() +
  geom_vline(xintercept = 0, linetype = "dotted", alpha = .3) +
  theme(plot.title = element_text(face = "bold"),
        plot.caption = element_text(face = "italic"))

centralPlots <- ggarrange(betw_centP, close_centP, str_centP, ncol=3, nrow=1)
ggsave("output/ENVcentralPlots.png", centralPlots, width = 10, height = 4)

betw_centO <- betw_cent %>% arrange(desc(mean))
close_centO <- close_cent %>% arrange(desc(mean))
str_centO <- str_cent %>% arrange(desc(mean))


### OLS models 
#### environmental orientation and cc 
summary(ccCNS <- lm(CNS ~ Ideology+environmentalist+enviro.move+age+female+educ+hhincome+urban, data = CCdata))
summary(ccNEP <- lm(NEP ~ Ideology+environmentalist+enviro.move+age+female+educ+hhincome+urban, data = CCdata))
summary(ccPUB <- lm(public ~ CNS+NEP+Ideology+environmentalist+enviro.move+age+female+educ+hhincome+urban, data = CCdata))
summary(ccPRI <- lm(private ~ CNS+NEP+Ideology+environmentalist+enviro.move+age+female+educ+hhincome+urban, data = CCdata))
summary(ccPEB <- lm(PEB ~ CNS+NEP+Ideology+environmentalist+enviro.move+age+female+educ+hhincome+urban, data = CCdata))

summary(ccNEP <- lm(NEP ~ Ideology+environmentalist+enviro.move+CNS+public+private, data = CCdata))


#### PEB, env, and cc models 
summary(ccPEBcc <- lm(PEB ~ CC_EH+CC_CI+Dem+Ideology+age+female+educ+hhincome+urban, data = CCdata))
summary(ccPEBcns <- lm(PEB ~ CNS+CC_EH+CC_CI+Dem+Ideology+age+female+educ+hhincome+urban, data = CCdata))
summary(ccPEBnep <- lm(PEB ~ NEP+CC_EH+CC_CI+Dem+Ideology+age+female+educ+hhincome+urban, data = CCdata))
summary(ccPEB <- lm(PEB ~ CNS+NEP+CC_EH+CC_CI+Ideology, data = CCdata))


names(CCdata)
### network of everything with behavior
combine2NetVars <- c("Ideology",
                     "environmentalist", "enviro.move",
                     "cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                     "cns8","cns9","cns10","cns11","cns12_r","cns13","cns14_r",
                     "nep1","nep2_r","nep3","nep4_r","nep5","nep6_r","nep7","nep8_r",
                     "nep9","nep10_r","nep11","nep12_r","nep13","nep14_r","nep15",
                     "public","private"
                     )
combine2NetData <- CCdata[combine2NetVars]

combine2NetNetwork <- estimateNetwork(combine2NetData, 
                                     default = "EBICglasso",
                                     corMethod = "cor_auto",
                                     tuning = 0.5)
groups <- factor(c(
  rep("IDEOL", 1),
  rep("ENV", 2),
  rep("CNS", 14),
  rep("NEP", 15),
  rep("BEHAVE", 2)
))

groups <- factor(as.character(groups), levels = c("IDEOL","ENV","CNS","NEP","BEHAVE"))

plot(combine2NetNetwork, layout = "spring", groups=groups, negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")
combine2NetNetwork$results$optnet

set.seed(1287) 
net_boot <- bootnet(combine2NetNetwork, nBoots = 100,
                    default = "EBICglasso",
                    statistics = c("betweenness","closeness","strength"),
                    type = "nonparametric", nCores = 1)

save(net_boot, file= paste0(getwd(),"/data/network_data_for_replication.RData"))

#### 
names(CCdata)

combine3NetVars <- c("cns1","cns2","cns3","cns4_r","cns5","cns6","cns7",
                     "cns8","cns9","cns10","cns11","cns12_r","cns13","cns14_r",
                     "nep1","nep2_r","nep3","nep4_r","nep5","nep6_r","nep7","nep8_r",
                     "nep9","nep10_r","nep11","nep12_r","nep13","nep14_r","nep15",
                     "act.org","cand","money.org","cont.off","cont.bus","petition",        
                     "meeting","product","water","buycott","recycle","energy","stocks"   
)
combine3NetData <- CCdata[combine3NetVars]

combine3NetNetwork <- estimateNetwork(combine3NetData, 
                                      default = "EBICglasso",
                                      corMethod = "cor_auto",
                                      tuning = 0.5)
groups <- factor(c(
  rep("CNS", 14),
  rep("NEP", 15),
  rep("BEHAVE", 13)
))

groups <- factor(as.character(groups), levels = c("CNS","NEP","BEHAVE"))

plot(combine3NetNetwork, layout = "spring", groups=groups, negDashed = T, legend = F, label.cex = .8, label.scale = T, details = F, theme = "gray")

set.seed(1287) 
net_boot <- bootnet(combine3NetNetwork, nBoots = 100,
                    default = "EBICglasso",
                    statistics = c("closeness"),
                    type = "nonparametric", nCores = 1)

save(net_boot, file= paste0(getwd(),"/data/network_data_for_replication.RData"))

summary(net_boot)
net_boot_whole <- net_boot$bootTable
net_boot_stat<-summary(net_boot)
net_boot_stat_cent <- net_boot_stat %>%
  filter(type!="edge")
cent_stat <- net_boot_stat_cent %>%
  dplyr::select(type, id, mean, CIlower, CIupper)
cent_stat$id

close_cent<- cent_stat %>%
  filter(type == "closeness")

close_centP <- ggplot(data = close_cent, aes(x=reorder(labels, mean), y=mean)) + 
  geom_point() +
  geom_errorbar(aes(ymin=(CIlower), ymax=(CIupper)), stat = "identity", position=position_dodge(0.1), width=.1) +
  coord_flip() +
  xlab("") +
  ylab("") + 
  ggtitle("Closeness") +
  theme_minimal() +
  geom_vline(xintercept = 0, linetype = "dotted", alpha = .3) +
  theme(plot.title = element_text(face = "bold"),
        plot.caption = element_text(face = "italic"))
