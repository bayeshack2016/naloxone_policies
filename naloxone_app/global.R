library(dplyr)

load('./../data/opioid_final.RData')
opioid$claim_pop <- opioid$Total.Claim.Count/opioid$pop14*1000
opioid$provider_pop <- opioid$Provider.Count/opioid$pop14*1000
try(opioid$cancer_incidence_per_1000 <- as.numeric(opioid$cancer_incidence_per_100000)/100)
opioid$arrests_1000 <- opioid$total_arrests/opioid$pop14*1000

allzips <- readRDS("./data/superzip.rds")
allzips$latitude <- jitter(allzips$latitude)
allzips$longitude <- jitter(allzips$longitude)
allzips$college <- allzips$college * 100
allzips$zipcode <- formatC(allzips$zipcode, width=5, format="d", flag="0")
row.names(allzips) <- allzips$zipcode
tmp <- read.csv('./../data/opioids_state_regulations.csv', stringsAsFactors = FALSE)
tmp <- tmp[-c(2,3)]
tmp$score <- (rowSums(tmp == 'Yes' | tmp == ' Yes')/12) * 100
tmp$score[is.na(tmp$score) | tmp$score == ''] <- 0
