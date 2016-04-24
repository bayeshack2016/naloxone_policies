# Naloxone Regulations Effects

HHS Prompt 2
Measuring causal effect of naloxone regulation policies on drug abuse deaths

## Prompt

The abuse and addiction to opioids such as heroin, morphine, and prescription pain relievers is one of the most serious health problems in the US today. An estimated 2.1 million people in the US suffer from substance use disorders related to prescription opioid pain relievers in 2012 and an estimated 467,000 addicted to heroin (National Institute of Drug Abuse)

Naloxone has been one of the most succesful drugs to help avoid deaths by opioids abuse. Naloxone blocks or reverses the effects of opioid medication and is used to treat a narcotic overdose in an emergency situation.

However, the access to naloxone varies highly across the country. While some states have very permissive laws that facilitate prescribers and dispensers to give naloxone to patients, other states have criminal, civil, and/or disciplinary charges to those prescribing or dispensing naloxone.

In this project we mimic an experiment setting to measure the effect of introducing permissive naloxone regulations in the number of deaths caused by drug intoxication. In addition, we provide an app that allows users to quickly identify the existing regulations in each county, as well as the levels of deaths by drug intoxication, the number of opioids providers, data on opioid consumption, among other relevant variables.

Our analysis shows that if states would introduce permissive regulations for prescribers or dispensers of naloxone could reduce total overdose related deaths by 1.5 per cent (the equivalent of 300 deaths a year for 2014).

## Data
In data/src you can find all the sources and data we used to estimate the effects of naloxone regulations. 
We used a combination of data sources, mainly CDC data and American Community Survey data.
Naloxone regulations were obtained from Corey Davis recollection (see his article in data/src/article). As our data was from 2014, we only counted those states with naloxone regulations prior to 2014.

## Estimation of causal effects:
To estimate the impact of state level restrictions and regulations of Naloxone sales, prescription, and possession, we built a county level dataset of age-adjusted death rates for drug poisoning per 100,000 population (based on CDC estimates), and merged it with county data from the 2013 American Community survey on demographics and sociographic characteristics. This data was combined with the provided CMS data on Medicare Part D prescription data.

We estimated Average Treatment Effects (ATE) of state level regulation through genetic matching using the R package genmatch.

Counties with similar characteristics in terms of poverty, race, age, veteran status, opioid prescription, and access to provides were matched to each other in a way that paired counties were as similar as possible on covariates and only differed in the existence of Naloxone related regulations.

Average Treatment Effects show the estimated impact of a change from restrictive to unrestrictive regulation on the poisoning related death rate.

## Results
Our analysis found that on average when states have laws that give immunity to prescribers and dispensers of naloxone, there is a 1.6 and 1.5 point decrease in the percentage of deaths caused by drug intoxication. For instance, a county that has 23 deaths per 100,000 citizens would reduce its numbers of deaths to 21.4 deaths per 100,000 citizens by passing naloxone regulations giving prescribers immunity (civil, criminal, and disciplinary).

To see the results we built a shiny app. The app shows a set of maps where the user can compare the number of deaths with the existing regulations (up to 2014), to what could happen (in terms of deaths caused by drugs intoxication) if states pass those regulations.

To visualize the results run the following code in R:

library(shiny)
runApp("(/path/to/project_root/naloxone_app")

## Team
Persephone Tsebelis (https://github.com/persephonet), Steffen Weiss (https://github.com/steffenweiss), Eugenia Giraudy (https://github.com/eugeniagiraudy)

## Dependencies
For the shiny app install the following packages:
  - shiny
  - leaflet
  - rcolorbrewer
  - scales
  - lattice
  - dplyr
  - raster

