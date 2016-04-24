library(openxlsx)
library(stringr)
library(plyr)
library(ggplot2)

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


vars <- c('immunity_prescribers_all', 'immunity_dispensers_all')

for(var in vars){
  treat <- I(opioid[[var]] == 'Yes')
  genout <- GenMatch(Tr=treat, X=X, BalanceMatrix=BalanceMat, 
    estimand="ATE", M=1, max.generations=10, wait.generations=1)
  #The outcome variable
  Y=opioid$ratesplit_low
  Y[is.na(Y)] <- 0
  # Now that GenMatch() has found the optimal weights, let's estimate
  # our causal effect of interest using those weights
  #
  mout <- Match(Y=Y, Tr=treat, X=X, estimand="ATE", Weight.matrix=genout)
  print(summary(mout))
  estimate <- mout$est
  opioid[[paste0('estimate_', var)]][opioid[[var]] %in% 'No'] <- opioid$ratesplit_low[opioid[[var]] %in% 'No'] - estimate
  opioid[[paste0('estimate_', var)]][opioid[[var]] %in% 'Yes'] <- opioid$ratesplit_low[opioid[[var]] %in% 'Yes']
}