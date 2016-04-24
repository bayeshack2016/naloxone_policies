library(openxlsx)
library(stringr)
library(plyr)
library(ggplot2)

setwd("/Users/steffen/Dropbox (YouGov Analytics)/Hack/")

claims <- read.xlsx("./data/src/CMS/Part_D_Opioid_Geographic_Data.xlsx", sheet=2)

deaths <- read.csv(file = "./data/src/cdc/NCHS_-_Drug_Poisoning_Mortality__County_Trends__United_States__1999_2014.csv", header = TRUE, stringsAsFactors = FALSE)

deaths <- deaths[, c("FIPS", "Year", "Population", "Estimated.Age.adjusted.Death.Rate..11.Categories..in.ranges.")]
names(deaths) <- c("FIPS", "Year", "pop14", "DeathRate")


deaths  <- deaths[deaths$Year == 2014, ]
 
deaths$DeathRate <- gsub(">", "", deaths$DeathRate)
deaths$ratesplit_low <- as.numeric(gsub("(^.*)-.*$", "\\1", deaths$DeathRate))
deaths$ratesplit_high <- as.numeric(gsub("(^.*)-(.*)$", "\\2", deaths$DeathRate))

opioid <- merge(claims, deaths, by='FIPS', all.x=TRUE, all.y=TRUE)

g <- ggplot(opioid[opioid$Percent.Opioid.Claims < 15, ], aes(y=ratesplit_low, x=Percent.Opioid.Claims)) + geom_point() + geom_smooth()

load("./data/src/census/sampleneeds.RData")
needed <- needed[!duplicated(needed$countyfips), ]
needed$countyfips <- as.integer(needed$countyfips)

opioid <- merge(opioid, needed, by.x="FIPS", by.y="countyfips")

load("./data/src/nat archive of criminal justice data/crime_by_county.RData")
df$fips <- as.integer(df$fips)

opioid <- merge(opioid, df, by.x="FIPS", by.y="fips", all.x=TRUE)

cancer <- read.csv(file = "./data/src/cdc/cancer_incidence_rate.csv", header = TRUE, stringsAsFactors = FALSE)

cancer <- cancer[cancer$FIPS != 0, c("FIPS", "cancer_incidence_per_100000")]
cancer$FIPS <- as.integer(cancer$FIPS)

opioid <- merge(opioid, cancer, by="FIPS", all.x=TRUE)

laws <- read.csv(file = "./data/opioids_state_regulations.csv", header = TRUE, stringsAsFactors = FALSE)
names(laws) <- gsub("X.", "", names(laws))

opioid <- merge(opioid, laws, by.x="State.Abbreviation", by.y="state", all.x=TRUE)

save(opioid, file="./data/opioid.RData")

