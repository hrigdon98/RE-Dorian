library(tidyverse)
distribution_data <- read_csv("https://www.cdc.gov/coronavirus/2019-ncov/json/covid-vaccines-data.csv") %>% 
  mutate(`Percent Jurisdiction`= Jurisdiction/`Total Deliveries`*100) %>% 
  mutate(`Percent Federal Pharmacy`= `Federal Retail Pharmacy Program`/`Total Deliveries`*100) %>% 
  mutate(`Percent FQHC`= `HRSA FQHC Program`/`Total Deliveries`*100) %>% 
  mutate(`Percent FEMA CVC`= `FEMA CVC Pilot Program`/`Total Deliveries`*100) %>%
  mutate(`Percent HHS/NIH`= `HHS/NIH Program`/`Total Deliveries`*100) %>% 
  mutate(`Percent Dialysis`= `Renal Dialysis Program`/`Total Deliveries`*100) %>%
  mutate(`Percent Federal Entities`= `Federal Entities`/`Total Deliveries`*100)
write.csv(distribution_data, "distributiondata.csv")
