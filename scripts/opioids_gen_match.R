library(openxlsx)
library(stringr)
library(plyr)
library(ggplot2)


setwd("~/Dropbox (YouGov Analytics)/Hack/")

load("./data/opioid.RData")


opioid$immunity_prescribers_all[opioid$immunity_prescribers_civil %in% 'Yes' & opioid$immunity_prescribers_criminal %in% 'Yes' & opioid$immunity_prescribers_disciplinary %in% 'Yes'] <- 'Yes'
opioid$immunity_prescribers_all[is.na(opioid$immunity_prescribers_all)] <- 'No'
opioid$immunity_prescribers_all[opioid$date %in% c('2014', '2015', '2013 and 2014', '2014 and 2015')] <- 'No'

opioid$immunity_dispensers_all[opioid$immunity_dispensers_civil %in% 'Yes' & opioid$immunity_dispensers_criminal %in% 'Yes' & opioid$immunity_dispensers_disciplinary %in% 'Yes'] <- 'Yes'
opioid$immunity_dispensers_all[is.na(opioid$immunity_dispensers_all)] <- 'No'
opioid$immunity_dispensers_all[opioid$date %in% c('2014', '2015', '2013 and 2014', '2014 and 2015')] <- 'No'


opioid$prescribin_permitted_third_party[opioid$date %in% c('2014', '2015', '2013 and 2014', '2014 and 2015')] <- 'No'
  
opioid$vetshare <- opioid$veteran/opioid$pop13

#The covariates we want to match on
opioid$Provider.Count[is.na(opioid$Provider.Count)] <- 0
X = opioid[, c("Percent.Opioid.Claims", "pop13", "age65", "whitealone", "vetshare", "povertyline", "Provider.Count")]
#The covariates we want to obtain balance on
BalanceMat <- opioid[, c("Percent.Opioid.Claims", "pop13", "age65", "whitealone", "vetshare", "povertyline", "Provider.Count")]


#opioid$prescribin_permitted_third_party[is.na(opioid$prescribin_permitted_third_party)] <- 'No'
treat <- I(opioid$prescribin_permitted_third_party == 'Yes')

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

###
estimate_immunity_prescribers_all <- mout$est
opioid$estimate_immunity_prescribers_all[opioid$immunity_prescribers_all %in% 'No'] <- opioid$ratesplit_low[opioid$immunity_prescribers_all %in% 'No'] - estimate_immunity_prescribers_all
opioid$estimate_immunity_prescribers_all[opioid$immunity_prescribers_all %in% 'Yes'] <- opioid$ratesplit_low[opioid$immunity_prescribers_all %in% 'Yes']

estimate_immunity_dispensers_all <- mout$est
opioid$estimate_immunity_dispensers_all[opioid$immunity_dispensers_all %in% 'No'] <- opioid$ratesplit_low[opioid$immunity_dispensers_all %in% 'No'] - estimate_immunity_dispensers_all
opioid$estimate_immunity_dispensers_all[opioid$immunity_dispensers_all %in% 'Yes'] <- opioid$ratesplit_low[opioid$immunity_dispensers_all %in% 'Yes']

estimate_prescribin_permitted_third_party <- mout$est
opioid$estimate_prescribin_permitted_third_party[opioid$prescribin_permitted_third_party %in% 'No'] <- opioid$ratesplit_low[opioid$prescribin_permitted_third_party %in% 'No'] - estimate_prescribin_permitted_third_party
opioid$estimate_prescribin_permitted_third_party[opioid$prescribin_permitted_third_party %in% 'Yes'] <- opioid$ratesplit_low[opioid$prescribin_permitted_third_party %in% 'Yes']
