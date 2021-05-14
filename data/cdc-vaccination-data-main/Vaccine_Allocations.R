library(tidyverse)
pfizer <- read_csv("https://data.cdc.gov/resource/saz5-9hgg.csv?$limit=50000") %>% 
  mutate(key= paste(jurisdiction, week_of_allocations)) %>% 
  rename(pfizer_1st_dose = `_1st_dose_allocations`) %>% 
  rename(pfizer_2nd_dose = `_2nd_dose_allocations`)
moderna <- read_csv("https://data.cdc.gov/resource/b7pe-5nws.csv?$limit=50000") %>% 
  mutate(key= paste(jurisdiction, week_of_allocations))%>% 
  rename(moderna_1st_dose = `_1st_dose_allocations`) %>% 
  rename(moderna_2nd_dose = `_2nd_dose_allocations`)
janssen <- read_csv("https://data.cdc.gov/resource/w9zu-fywh.csv?$limit=50000") %>% 
  mutate(key= paste(jurisdiction, week_of_allocations)) %>% 
  rename(janssen_1st_dose = `_1st_dose_allocations`)
pfizer_moderna <- left_join(pfizer, moderna, by = "key")
allocations <- left_join(pfizer_moderna, janssen, by = "key") %>% 
  select(jurisdiction.x, week_of_allocations.x, pfizer_1st_dose, pfizer_2nd_dose, moderna_1st_dose, moderna_2nd_dose, janssen_1st_dose) %>% 
  rename(jurisdiction = jurisdiction.x) %>% 
  rename(week_of_allocations = week_of_allocations.x) %>% 
  mutate(pfizer_1st_dose = replace_na(pfizer_1st_dose, 0)) %>%
  mutate(pfizer_2nd_dose = replace_na(pfizer_2nd_dose, 0)) %>%
  mutate(moderna_1st_dose = replace_na(moderna_1st_dose, 0)) %>%
  mutate(moderna_2nd_dose = replace_na(moderna_2nd_dose, 0)) %>%
  mutate(janssen_1st_dose = replace_na(janssen_1st_dose, 0)) %>% 
  mutate(total = pfizer_1st_dose + pfizer_2nd_dose + moderna_1st_dose + moderna_2nd_dose + janssen_1st_dose)
allocations_total <- allocations %>% 
  group_by(week_of_allocations) %>% 
  summarise(pfizer_1st_dose = sum (pfizer_1st_dose), pfizer_2nd_dose = sum (pfizer_2nd_dose), moderna_1st_dose = sum (moderna_1st_dose), moderna_2nd_dose = sum (moderna_2nd_dose), janssen_1st_dose = sum (janssen_1st_dose), total = sum(total))
write.csv(allocations, "weekly_allocations.csv", row.names = F, na = "")
write.csv(allocations_total, "total_weekly_allocations.csv", row.names = F, na = "")
