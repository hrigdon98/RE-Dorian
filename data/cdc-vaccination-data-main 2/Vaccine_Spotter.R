library(tidyverse)
library(jsonlite)
vaccine_spotter <- fromJSON("https://www.vaccinespotter.org/api/v0/US.json")
locations <- vaccine_spotter[['features']]
geometry <- locations[['geometry']]
properties <- locations[['properties']] %>% 
  select(id, url, city, name, state, address, provider, postal_code, carries_vaccine, appointments_available, appointments_available_all_doses, appointments_available_2nd_dose_only)
separatefunction <- function(geometry) {
  ListCols <- sapply(geometry, is.list)
  cbind(geometry[!ListCols], t(apply(geometry[ListCols], 1, unlist)))}
coordinates <- separatefunction(geometry) %>% 
  rename(Longitude = coordinates1, Latitude = coordinates2)
vaccine_sites <- cbind(coordinates, properties)
zipcodes <- read_csv("https://query.data.world/s/vzf5lehvrlmq5udksvjisdqnl6dsmp", col_types = list(.default = col_character()))
vaccine_sites2 <- left_join(vaccine_sites, zipcodes, by = c("postal_code" = "ZIP"))
counties <- read_csv("https://raw.githubusercontent.com/bhrenton/cdc-vaccination-data/main/Counties%20Vaccine%20Reference.csv")
vaccine_counties <- vaccine_sites2 %>%
  filter(appointments_available == "TRUE") %>% 
  group_by(STCOUNTYFP) %>%
  summarize(available_pharmacies = n())
vaccine_counties2 <- left_join(counties, vaccine_counties, by = c("New FIPS" = "STCOUNTYFP")) %>% 
  mutate(pharmaciesper100k = available_pharmacies/Total_Population*100000)
counties_vaccine <- read_csv("https://raw.githubusercontent.com/bhrenton/cdc-vaccination-data/main/vaccination_county.csv")
vaccine_counties3 <- left_join(vaccine_counties2, counties_vaccine, by = c("New FIPS" = "FIPS"))
vaccine_states <- vaccine_sites %>% 
  mutate(available_pharmacy = ifelse(appointments_available == "TRUE",1,0)) %>%
  group_by(state) %>% 
  summarise(n_pharmacies = n(), available_pharmacies= sum(available_pharmacy,na.rm = TRUE)) %>% 
  mutate(pct_available = available_pharmacies/n_pharmacies*100)
write.csv(vaccine_counties3, "vaccine_counties_sites.csv",row.names=F, na="")
write.csv(vaccine_sites, "vaccine_spotter_sites.csv", row.names=F, na="")
write.csv(vaccine_states, "vaccine_spotter_states.csv", row.names=F, na="")
