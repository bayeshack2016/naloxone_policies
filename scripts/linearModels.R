library(Matching)

library(openxlsx)
library(stringr)
library(plyr)
library(ggplot2)
library(Matching)

setwd("/Users/steffen/Dropbox (YouGov Analytics)/Hack/")

load("./data/opioid.RData")
opioid$vetshare <- opioid$veteran/opioid$pop13
opioid$claimpop <- opioid$Opioid.Claim.Count/opioid$pop13

lm1 <- lm(ratesplit_low ~ vetshare + pop13 + Opioid.Claim.Count + whitenonhisp + as.numeric(cancer_incidence_per_100000) + as.factor(naloxone_law) + as.factor(prescribin_permitted_third_party)+ drug_arrests + drunk + as.factor(State.FIPS), data=opioid)
summary(lm1)


#The covariates we want to match on
X = opioid[, c("Percent.Opioid.Claims", "pop13", "age65", "whitealone", "vetshare", "povertyline")]

#The covariates we want to obtain balance on
BalanceMat <- opioid[, c("Percent.Opioid.Claims", "pop13", "age65", "whitealone", "vetshare", "povertyline")]
#
opioid$naloxone_law[is.na(opioid$naloxone_law)] <- 'No'
treat <- I(opioid$naloxone_law == 'Yes')

genout <- GenMatch(Tr=treat, X=X, BalanceMatrix=BalanceMat, 
    estimand="ATE", M=1, max.generations=10, wait.generations=1)

#The outcome variable
Y=opioid$ratesplit_low
Y[is.na(Y)] <- 0
#
# Now that GenMatch() has found the optimal weights, let's estimate
# our causal effect of interest using those weights
#
mout <- Match(Y=Y, Tr=treat, X=X, estimand="ATE", Weight.matrix=genout)
summary(mout)

mb <- MatchBalance(I(naloxone_law == 'Yes') ~ Percent.Opioid.Claims + pop13 + age65 + whitealone + vetshare + povertyline, 
    data=opioid, match.out=mout, nboots=500)