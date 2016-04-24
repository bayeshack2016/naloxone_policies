
load('./opioid.RData')

county_df <- read.csv("src/county_to_zipcode.csv", header=TRUE, stringsAsFactors=FALSE)



for(i in 1:length(opioid$FIPS)){
  fips <- opioid$FIPS[i]
  likelihood <- county_df$afac[county_df$county %in% fips]
  zcta5 <- county_df$zcta5[county_df$county %in% fips]
  if(likelihood %in% 1){
    opioid$zcta5[i] <- county_df$zcta5[county_df$county %in% fips]
  }else{
    opioid$zcta5[i] <- sample(zcta5, size=1, prob=likelihood, replace=TRUE)  
  }
  
  print(i)
}

save(opioid, file='opioid_zipcode.RData')
