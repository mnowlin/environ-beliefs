## Script for cleaning and analysis of environmental values/attitudes

## PS 294 class project and APSA paper

# First analysis by AS

#set wd

# load in data
envatt <- read.csv('data/apsa17.csv', header = T, stringsAsFactors = FALSE, na.strings=c(""," ","NA"))
attach(envatt)
#load packages
#install.packages("psych")
#install.packages("MASS")
#install.packages("GPArotation")
#install.packages("ltm")
#install.packages("foreign")
#install.packages("psy")
#install.packages("stargazer")
#install.packages("nFactors")
library(psych)

library(nFactors)

# clean data
# controls
#age
envatt$age <- q75

# female dummy
envatt$female <- NA
envatt$female[which(q76 == 2)] <- 1
envatt$female[which(q76 != 2)] <- 0

#income
envatt$hhincome <- q83

#libcon
#Ideology, add havent thought about it to moderates
envatt$Ideology <- NA
envatt$Ideology[which(q80 == 1)] <- 1
envatt$Ideology[which(q80 == 2)] <- 2
envatt$Ideology[which(q80 == 3)] <- 3
envatt$Ideology[which(q80 == 4)] <- 4
envatt$Ideology[which(q80 == 5)] <- 5
envatt$Ideology[which(q80 == 6)] <- 6
envatt$Ideology[which(q80 == 7)] <- 7
envatt$Ideology[which(q80 == 8)] <- 4

# Democrat dummy
envatt$Dem <- NA
envatt$Dem[which(q78 == 1)] <- 1
envatt$Dem[which(q78 != 1)] <- 0
envatt$Dem[which(q79c == 1)] <- 1                  
envatt$Dem[which(q79c != 1)] <- 0
    
# Republican dummy
envatt$Rep <- NA
envatt$Rep[which(q78 == 2)] <- 1
envatt$Rep[which(q78 != 2)] <- 0
envatt$Rep[which(q79c == 2)] <- 1 

# urban = rural low, urban high
envatt$urban <- q81

#education
envatt$educ <- q82

# sample descriptives
demos <- subset(envatt, select = c("educ", "hhincome", "Dem", "female", "Ideology", "age", "urban" ))

table <- describe(demos)
describe(demos)  
  

# create indexes
# cultural cognition scale
# egal-hier
envatt$cc_eh_1 <- q1x31_1
envatt$cc_eh_2 <- q1x31_2
envatt$cc_eh_3 <- q1x31_3
envatt$cc_eh_4 <- q1x31_4
envatt$cc_eh_5 <- q1x31_5
envatt$cc_eh_6 <- q1x31_6
envatt$cc_eh_7 <- q1x31_7

envatt$cc_eh_8 <- NA
envatt$cc_eh_8[which(q1x31_8==4)] <- 1
envatt$cc_eh_8[which(q1x31_8==3)] <- 2
envatt$cc_eh_8[which(q1x31_8==2)] <- 3
envatt$cc_eh_8[which(q1x31_8==1)] <- 4

envatt$cc_eh_9 <- NA
envatt$cc_eh_9[which(q1x31_9==4)] <- 1
envatt$cc_eh_9[which(q1x31_9==3)] <- 2
envatt$cc_eh_9[which(q1x31_9==2)] <- 3
envatt$cc_eh_9[which(q1x31_9==1)] <- 4

envatt$cc_eh_10 <- NA
envatt$cc_eh_10[which(q1x31_10==4)] <- 1
envatt$cc_eh_10[which(q1x31_10==3)] <- 2
envatt$cc_eh_10[which(q1x31_10==2)] <- 3
envatt$cc_eh_10[which(q1x31_10==1)] <- 4

envatt$cc_eh_11 <- NA
envatt$cc_eh_11[which(q1x31_11==4)] <- 1
envatt$cc_eh_11[which(q1x31_11==3)] <- 2
envatt$cc_eh_11[which(q1x31_11==2)] <- 3
envatt$cc_eh_11[which(q1x31_11==1)] <- 4

envatt$cc_eh_12 <- NA
envatt$cc_eh_12[which(q1x31_12==4)] <- 1
envatt$cc_eh_12[which(q1x31_12==3)] <- 2
envatt$cc_eh_12[which(q1x31_12==2)] <- 3
envatt$cc_eh_12[which(q1x31_12==1)] <- 4

envatt$cc_eh_13 <- NA
envatt$cc_eh_13[which(q1x31_13==4)] <- 1
envatt$cc_eh_13[which(q1x31_13==3)] <- 2
envatt$cc_eh_13[which(q1x31_13==2)] <- 3
envatt$cc_eh_13[which(q1x31_13==1)] <- 4

envatt$cc_eh_14 <- NA
envatt$cc_eh_14[which(q1x31_14==4)] <- 1
envatt$cc_eh_14[which(q1x31_14==3)] <- 2
envatt$cc_eh_14[which(q1x31_14==2)] <- 3
envatt$cc_eh_14[which(q1x31_14==1)] <- 4

# combine for egalitarianism-hierarchilism scale
envatt$CC_EH <- rowMeans(envatt[c("cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14" )], na.rm= T)

#comm-ind
envatt$cc_ci_1 <- q1x31_15
envatt$cc_ci_2 <- q1x31_16
envatt$cc_ci_3 <- q1x31_17
envatt$cc_ci_4 <- q1x31_18
envatt$cc_ci_5 <- q1x31_19
envatt$cc_ci_6 <- q1x31_20
envatt$cc_ci_7 <- q1x31_21
envatt$cc_ci_8 <- q1x31_22
envatt$cc_ci_9 <- q1x31_23
envatt$cc_ci_10 <- q1x31_24
envatt$cc_ci_11 <- q1x31_25
envatt$cc_ci_12 <- q1x31_26


envatt$cc_ci_13 <- NA
envatt$cc_ci_13[which(q1x31_27==4)] <- 1
envatt$cc_ci_13[which(q1x31_27==3)] <- 2
envatt$cc_ci_13[which(q1x31_27==2)] <- 3
envatt$cc_ci_13[which(q1x31_27==1)] <- 4

envatt$cc_ci_14 <- NA
envatt$cc_ci_14[which(q1x31_28==4)] <- 1
envatt$cc_ci_14[which(q1x31_28==3)] <- 2
envatt$cc_ci_14[which(q1x31_28==2)] <- 3
envatt$cc_ci_14[which(q1x31_28==1)] <- 4

envatt$cc_ci_15 <- NA
envatt$cc_ci_15[which(q1x31_29==4)] <- 1
envatt$cc_ci_15[which(q1x31_29==3)] <- 2
envatt$cc_ci_15[which(q1x31_29==2)] <- 3
envatt$cc_ci_15[which(q1x31_29==1)] <- 4

envatt$cc_ci_16 <- NA
envatt$cc_ci_16[which(q1x31_30==4)] <- 1
envatt$cc_ci_16[which(q1x31_30==3)] <- 2
envatt$cc_ci_16[which(q1x31_30==2)] <- 3
envatt$cc_ci_16[which(q1x31_30==1)] <- 4

envatt$cc_ci_17 <- NA
envatt$cc_ci_17[which(q1x31_31==4)] <- 1
envatt$cc_ci_17[which(q1x31_31==3)] <- 2
envatt$cc_ci_17[which(q1x31_31==2)] <- 3
envatt$cc_ci_17[which(q1x31_31==1)] <- 4

#combine for communitarian-individualism scale
# removing cc_ci_10 per Eric's instruction July 26
envatt$CC_CI <- rowMeans(envatt[c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9", "cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17" )], na.rm= T)

# combine for complete cultural cognition scale
envatt$CC <- rowMeans(envatt[c("CC_EH", "CC_CI")])


# NEP

envatt$nep1 <- q46x59_46
envatt$nep2 <- q46x59_47
envatt$nep3 <- q46x59_48
envatt$nep4 <- q46x59_491
envatt$nep5 <- q46x59_492
envatt$nep6 <- q46x59_50
envatt$nep7 <- q46x59_51
envatt$nep8 <- q46x59_52
envatt$nep9 <- q46x59_53
envatt$nep10 <- q46x59_54
envatt$nep11 <- q46x59_55
envatt$nep12 <- q46x59_56
envatt$nep13 <- q46x59_57
envatt$nep14 <- q46x59_58
envatt$nep15 <- q46x59_59

envatt$nep2_r <- 6-envatt$nep2
envatt$nep4_r <- 6-envatt$nep4
envatt$nep6_r <- 6-envatt$nep6
envatt$nep8_r <- 6-envatt$nep8
envatt$nep10_r <- 6-envatt$nep10
envatt$nep12_r <- 6-envatt$nep12
envatt$nep14_r <- 6-envatt$nep14

#combine to create scale

envatt$NEPa <- rowMeans(envatt[c("nep1", "nep2_r", "nep3", "nep4_r", "nep5", "nep6_r", "nep7", "nep8_r", "nep9", "nep10_r", "nep11", "nep12_r", "nep13", "nep14_r", "nep15")], na.rm=TRUE)

# reverse scale
envatt$NEP <- 6-envatt$NEPa

# CNS

envatt$cns1 <- q32x45_32
envatt$cns2 <- q32x45_33
envatt$cns3 <- q32x45_34
envatt$cns4 <- q32x45_35
envatt$cns5 <- q32x45_36
envatt$cns6 <- q32x45_37
envatt$cns7 <- q32x45_38
envatt$cns8 <- q32x45_39
envatt$cns9 <- q32x45_40
envatt$cns10 <- q32x45_41
envatt$cns11 <- q32x45_42
envatt$cns12 <- q32x45_43
envatt$cns13 <- q32x45_44
envatt$cns14 <- q32x45_45

# reverse
envatt$cns4_r <- 6-envatt$cns4
envatt$cns12_r <- 6-envatt$cns12
envatt$cns14_r <- 6-envatt$cns14

# combine to create scale
envatt$CNSa <- rowMeans(envatt[c("cns1","cns2","cns3","cns4_r","cns5","cns6", "cns7","cns8", "cns9","cns10", "cns12_r", "cns11", "cns13", "cns14_r")], na.rm=TRUE)

#reverse
envatt$CNS <- 6-envatt$CNSa

# DV - Environmental behaviors
# first creat dummy for doing each behavior or not

envatt$product <- NA
envatt$product[which(q62x74_62==1)] <- 1
envatt$product[which(q62x74_62!=1)] <- 0

envatt$act.org <- NA
envatt$act.org[which(q62x74_63==1)] <- 1
envatt$act.org[which(q62x74_63!=1)] <- 0

envatt$cand <- NA
envatt$cand[which(q62x74_64==1)] <- 1
envatt$cand[which(q62x74_64!=1)] <- 0

envatt$money.org <- NA
envatt$money.org[which(q62x74_65==1)] <- 1
envatt$money.org[which(q62x74_65!=1)] <- 0

envatt$cont.off <- NA
envatt$cont.off[which(q62x74_66==1)] <- 1
envatt$cont.off[which(q62x74_66!=1)] <- 0

envatt$cont.bus <- NA
envatt$cont.bus[which(q62x74_67==1)] <- 1
envatt$cont.bus[which(q62x74_67!=1)] <- 0

envatt$petition <- NA
envatt$petition[which(q62x74_68==1)] <- 1
envatt$petition[which(q62x74_68!=1)] <- 0

envatt$meeting <- NA
envatt$meeting[which(q62x74_69==1)] <- 1
envatt$meeting[which(q62x74_69!=1)] <- 0

envatt$water <- NA
envatt$water[which(q62x74_70==1)] <- 1
envatt$water[which(q62x74_70!=1)] <- 0

envatt$buycott <- NA
envatt$buycott[which(q62x74_71==1)] <- 1
envatt$buycott[which(q62x74_71!=1)] <- 0

envatt$recycle <- NA
envatt$recycle[which(q62x74_72==1)] <- 1
envatt$recycle[which(q62x74_72!=1)] <- 0

envatt$energy <- NA
envatt$energy[which(q62x74_73==1)] <- 1
envatt$energy[which(q62x74_73!=1)] <- 0

envatt$stocks <- NA
envatt$stocks[which(q62x74_74==1)] <- 1
envatt$stocks[which(q62x74_74!=1)] <- 0

#add all together to create index
envatt$public <- rowSums(envatt[c("act.org", "cand", "money.org", "cont.off", "cont.bus", "petition", "meeting")], na.rm=TRUE)

# drop stocks per July 2020 review from AE (doesn't load)
envatt$private <- rowSums(envatt[c("product", "water", "buycott", "recycle", "energy")], na.rm=TRUE)

envatt$PEB <- rowSums(envatt[c("public","private", "stocks")])

# descriptives on each index

key.var <- subset(envatt, select = c("NEP", "CNS", "CC_EH", "CC_CI", "CC", "public", "private", "PEB" ))

table <- describe(key.var)
describe(key.var)

hist(envatt$PEB)
#hist(envatt$MES)
hist(envatt$NEP)
hist(envatt$CNS)
hist(envatt$CC_EH)
hist(envatt$CC_CI)
hist(envatt$CC)
hist(envatt$public)
hist(envatt$private)
#hist(envatt$environmentalist)
#hist(envatt$enviro.move)


### psychometrics

# First cronbach then exploratory factor analysis
# public peb
#cronbach(envatt[c("act.org", "cand", "money.org", "cont.off", "cont.bus", "petition", "meeting")])
#private peb
alpha(envatt[c("product", "water", "buycott", "recycle", "energy")])
#all peb
alpha(envatt[c("product", "water", "buycott", "recycle", "energy", "stocks","act.org", "cand", "money.org", "cont.off", "cont.bus", "petition", "meeting")])



#efa
# efa on private
pebp <- subset(envatt, select = c("product", "water", "buycott", "recycle", "energy"))

pebPrfa <- na.omit(pebp)
pebPr.cormat <- cor(pebPrfa)
pebPr.ev <- eigen(pebPr.cormat) # get eigenvalues
pebPr.ap <- parallel(subject=nrow(pebPrfa),var=ncol(pebPrfa),
                   rep=100,cent=.05)
pebPr.nS <- nScree(x=pebPr.ev$values, aparallel=pebPr.ap$eigen$qevpea)
plotnScree(pebPr.nS)

# two factors
# EFA to get factor loadings

pebPr.efa <- fa(pebPrfa, nfactors = 2, rotate = "varimax")
print(pebPr.efa)
#fa2latex(pebPr.efa)

# efa on public
pebpu <- subset(envatt, select = c("act.org", "cand", "money.org", "cont.off", "cont.bus", "petition", "meeting"))

pebPufa <- na.omit(pebpu)
pebPu.cormat <- cor(pebPufa)
pebPu.ev <- eigen(pebPu.cormat) # get eigenvalues
pebPu.ap <- parallel(subject=nrow(pebPufa),var=ncol(pebPufa),
                     rep=100,cent=.05)
pebPu.nS <- nScree(x=pebPu.ev$values, aparallel=pebPu.ap$eigen$qevpea)
plotnScree(pebPu.nS)

# two factors
# EFA to get factor loadings

pebPu.efa <- fa(pebPufa, nfactors = 2, rotate = "varimax")
print(pebPu.efa)
#fa2latex(pebPu.efa)

# efa on composite
pebd <- subset(envatt, select = c("product", "water", "buycott", "recycle", "energy", "stocks","act.org", "cand", "money.org", "cont.off", "cont.bus", "petition", "meeting"))

describe(pebd)

pebfa <- na.omit(pebd)
peb.cormat <- cor(pebfa)
peb.ev <- eigen(peb.cormat) # get eigenvalues
peb.ap <- parallel(subject=nrow(pebfa),var=ncol(pebfa),
                   rep=100,cent=.05)
peb.nS <- nScree(x=peb.ev$values, aparallel=peb.ap$eigen$qevpea)
plotnScree(peb.nS)

write.csv(peb.cormat, "pebcormat.csv")
write.csv(pebd, "pebdata.csv")

# two factors
# EFA to get factor loadings

peb.efa <- fa(pebfa, nfactors = 2, rotate = "varimax")
print(peb.efa)
#fa2latex(peb.efa)



#NEP
cronbach(envatt[c("nep1", "nep2_r", "nep3", "nep4_r", "nep5", "nep6_r", "nep7", "nep8_r", "nep9", "nep10_r", "nep11", "nep12_r", "nep13", "nep14_r", "nep15")])

nepd <- subset(envatt, select = c("nep1", "nep2_r", "nep3", "nep4_r", "nep5", "nep6_r", "nep7", "nep8_r", "nep9", "nep10_r", "nep11", "nep12_r", "nep13", "nep14_r", "nep15"))

nepfa <- na.omit(nepd)
nep.cormat <- cor(nepfa)
nep.ev <- eigen(nep.cormat) # get eigenvalues
nep.ap <- parallel(subject=nrow(nepfa),var=ncol(nepfa),
                   rep=100,cent=.05)
nep.nS <- nScree(x=nep.ev$values, aparallel=nep.ap$eigen$qevpea)
plotnScree(nep.nS)

#single factor
# EFA to get factor loadings

nep.efa <- fa(nepfa, nfactors = 1, rotate = "varimax")
print(nep.efa)
fa2latex(nep.efa)

#CNS
cronbach(envatt[c("cns1","cns2","cns3","cns4_r","cns5","cns6", "cns7","cns8", "cns9","cns10","cns11", "cns12_r", "cns13", "cns14_r")])

cnsd <- subset(envatt, select = c("cns1","cns2","cns3","cns4_r","cns5","cns6", "cns7","cns8", "cns9","cns10", "cns11", "cns12_r", "cns13", "cns14_r"))

cnsfa <- na.omit(cnsd)
cns.cormat <- cor(cnsfa)
cns.ev <- eigen(cns.cormat) # get eigenvalues
cns.ap <- parallel(subject=nrow(cnsfa),var=ncol(cnsfa),
                   rep=100,cent=.05)
cns.nS <- nScree(x=cns.ev$values, aparallel=cns.ap$eigen$qevpea)
plotnScree(cns.nS)

#single factor
# EFA to get factor loadings

cns.efa <- fa(cnsfa, nfactors = 1, rotate = "varimax")
print(cns.efa)
fa2latex(cns.efa)


#Cultural cognition
# comm-ind
cronbach(envatt[c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9", "cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17")])

CId <- subset(envatt, select = c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9","cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17"))

CIfa <- na.omit(CId)
CI.cormat <- cor(CIfa)
CI.ev <- eigen(CI.cormat) # get eigenvalues
CI.ap <- parallel(subject=nrow(CIfa),var=ncol(CIfa),
                   rep=100,cent=.05)
CI.nS <- nScree(x=CI.ev$values, aparallel=CI.ap$eigen$qevpea)
plotnScree(CI.nS)

#single factor
# EFA to get factor loadings

CI.efa <- fa(CIfa, nfactors = 1, rotate = "varimax")
print(CI.efa)
fa2latex(CI.efa)

# Egal-Hier
cronbach(envatt[c("cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14")])

EHd <- subset(envatt, select = c("cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14"))

EHfa <- na.omit(EHd)
EH.cormat <- cor(EHfa)
EH.ev <- eigen(EH.cormat) # get eigenvalues
EH.ap <- parallel(subject=nrow(EHfa),var=ncol(EHfa),
                  rep=100,cent=.05)
EH.nS <- nScree(x=EH.ev$values, aparallel=EH.ap$eigen$qevpea)
plotnScree(EH.nS)

#single factor
# EFA to get factor loadings

EH.efa <- fa(EHfa, nfactors = 1, rotate = "varimax")
print(EH.efa)
fa2latex(EH.efa)

# composite cultural cogn.

cronbach((envatt[c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9","cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17","cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14")]))

CCd <- subset(envatt, select=c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9", "cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17","cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14"))

CCfa <- na.omit(CCd)
CC.cormat <- cor(CCfa)
CC.ev <- eigen(CC.cormat) # get eigenvalues
CC.ap <- parallel(subject=nrow(CCfa),var=ncol(CCfa),
                  rep=100,cent=.05)
CC.nS <- nScree(x=CC.ev$values, aparallel=CC.ap$eigen$qevpea)
plotnScree(CC.nS)

#single factor
# EFA to get factor loadings

CC.efa <- fa(CCfa, nfactors = 1, rotate = "varimax")
print(CC.efa)
fa2latex(CC.efa)


## environmentalist identity

#strong environmnetalist

envatt$environmentalist <- NA
envatt$environmentalist[which(hidqenvironmentalist == 3)] <- 1
envatt$environmentalist[which(hidqenvironmentalist != 3)] <- 0

# identify with movement

envatt$enviro.move <- q61

######################### put all variables into single FA

BIGdata <- subset(envatt, select=c("cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9", "cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17","cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14","cns1","cns2","cns3","cns4_r","cns5","cns6", "cns7","cns8", "cns9","cns10", "cns11", "cns12_r", "cns13", "cns14_r", "nep1", "nep2_r", "nep3", "nep4_r", "nep5", "nep6_r", "nep7", "nep8_r", "nep9", "nep10_r", "nep11", "nep12_r", "nep13", "nep14_r", "nep15", "environmentalist", "enviro.move"))

BIGfa <- na.omit(BIGdata)
BIG.cormat <- cor(BIGfa)
BIG.ev <- eigen(BIG.cormat) # get eigenvalues
BIG.ap <- parallel(subject=nrow(BIGfa),var=ncol(BIGfa),
                  rep=100,cent=.05)
BIG.nS <- nScree(x=BIG.ev$values, aparallel=BIG.ap$eigen$qevpea)
plotnScree(BIG.nS)

#write correlationa matrix to csv
write.csv(BIG.cormat, "cormatrix.csv")
tab2 <- describe(BIGfa)
write.csv(tab2, "descriptives.csv")
#single factor
# EFA to get factor loadings

BIG.efa <- fa(BIGfa, nfactors = 5, rotate = "varimax")
print(BIG.efa)
fa2latex(BIG.efa)
semplot

cleandat <- subset(envatt, select=c("PEB", "educ", "hhincome", "Dem", "female", "Ideology",
                                    "age", "urban", "public" ,"private", "NEP", "CNS", "environmentalist",
                                    "enviro.move", "CC_EH", "CC_CI", "age", "act.org", "cand", "money.org", "cont.off", "cont.bus", "petition", "meeting", "product", "water", "buycott", "recycle", "energy", "stocks", "nep1", "nep2_r", "nep3", "nep4_r", "nep5", "nep6_r", "nep7", "nep8_r", "nep9", "nep10_r", "nep11", "nep12_r", "nep13", "nep14_r", "nep15", "cns1","cns2","cns3","cns4_r","cns5","cns6", "cns7","cns8", "cns9","cns10", "cns11", "cns12_r", "cns13", "cns14_r",
                                    "cc_ci_1","cc_ci_2","cc_ci_3","cc_ci_4","cc_ci_5","cc_ci_6","cc_ci_7","cc_ci_8","cc_ci_9", "cc_ci_11","cc_ci_12","cc_ci_13","cc_ci_14","cc_ci_15","cc_ci_16","cc_ci_17",
                                    "cc_eh_1","cc_eh_2","cc_eh_3","cc_eh_4","cc_eh_5","cc_eh_6","cc_eh_7","cc_eh_8","cc_eh_9","cc_eh_10","cc_eh_11","cc_eh_12","cc_eh_13","cc_eh_14"))
write.csv(cleandat, "cleandat.csv")


