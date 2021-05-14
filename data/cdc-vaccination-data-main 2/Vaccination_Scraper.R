library(tidyverse)
library(jsonlite)
table1 <- fromJSON("https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_trends_data")
trends<-table1[['vaccination_trends_data']]
table2 <- fromJSON("https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_county_condensed_data")
counties<-table2[['vaccination_county_condensed_data']]
table3 <- fromJSON("https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_demographics_data")
demographics<-table3[['vaccination_demographics_data']]
table4 <- fromJSON("https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data")
vaccination<-table4[['vaccination_data']]
table5 <- fromJSON("https://www.cdc.gov/coronavirus/2019-ncov/modules/transmission/variant-cases.json")
variants<-table5[['data']] %>% 
  filter(filter == "Variant B.1.1.7")
write.csv(demographics, "vaccination_demographics.csv",row.names=F, na = "")
write.csv(vaccination, "vaccination_data.csv",row.names=F, na = "")
write.csv(counties, "vaccination_county.csv",row.names=F, na = "")
write.csv(trends, "vaccination_trends.csv",row.names=F, na = "")
write.csv(variants, "variants.csv",row.names=F, na = "")
