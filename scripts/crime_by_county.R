setwd("~/Downloads/ICPSR_35019/DS0004/") 

load("35019-0004-Data.rda")
df <- da35019.0001
names(df) <- tolower(names(df))

df <- df[, c('fips_st', 'fips_cty',  'drugtot', 'drgsale', 'cocsale', 'drgposs', 'cocposs', 'drunk', 'grndtot')] # Cocaine possasion
names(df)[9] <- 'total_arrests'
names(df)[3] <- 'drug_arrests'
df$fips_st <- formatC(df$fips_st, flag=0, width=2)
df$fips_cty <- formatC(df$fips_cty, flag=0, width=3)
df$fips <- paste0(df$fips_st, df$fips_cty) 

save(df, file='~/Dropbox (YouGov Analytics)/Hack/data/src/crime_by_county.RData')
