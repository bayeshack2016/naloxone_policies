# Naloxone Regulations Effects

Measuring causal effect of naloxone regulation policies on drug abuse deaths

## Prompt

The abuse and addiction to opioids such as heroin, morphine, and prescription pain relievers is one of the most serious health problems in the US today. An estimated 2.1 million people in the US suffer from substance use disorders related to prescription opioid pain relievers in 2012 and an estimated 467,000 addicted to heroin (National Institute of Drug Abuse)

## Data
In data/src you can find all the sources and data we used to estimate the effects of naloxone regulations. 
We used a combination of data sources, mainly CDC data and American Community Survey data.
Naloxone regulations were obtained from Corey Davis recollection (see his article in data/src/article). As our data was from 2014, we only counted those states with naloxone regulations prior to 2014.

# Methods

## Results
Our analysis found that when states have laws that give immunity to prescribers and dispensers of naloxone, there is a 1.6 and 1.5 point decrease in the percentage of deaths caused by drug intoxication. For instance, a county that has 23 deaths per 100,000 citizens would reduce its numbers of deaths to 22.4 deaths per 100,000 citizens by passing naloxone regulations.

To see the results we built a shiny app. The app shows a set of maps where the user can compare the number of deaths with the existing regulations (up to 2014), to what could happen (in terms of deaths caused by drugs intoxication) if states pass those regulations.

To visualize the results run the following code in R:

library(shiny)
runApp("(path_to_project)/naloxone") 

## Team
Persephone Tsebelis, Steffen Weiss, Eugenia Giraudy


