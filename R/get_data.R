
library(httr)
library(jsonlite)
library(tidyverse)
library(here)


# read in manual data
manual = read_csv(here("data", "manual-submissions.csv")) %>%
  mutate(clinicaltrialsgov = 0)

print("Read data")

res = GET("https://clinicaltrials.gov/api/query/study_fields?expr=aphasia+AND+AREA%5BOverallStatus%5DRecruiting&fields=BriefTitle%2C+Condition%2C+StartDate%2C+NCTId%2C+OrgFullName%2C+OverallStatus%2C+BriefSummary%2C+DetailedDescription%2C+Keyword%2C+StudyType%2C+EligibilityCriteria%2C+HealthyVolunteers%2C+MinimumAge%2C+Gender%2C+LocationCity%2C+LocationZip%2C+LocationState%2C+ResponsiblePartyInvestigatorFullName%2C+LocationCountry&min_rnk=1&max_rnk=500&fmt=json")

print("pulled from ct.gov")

#source(here("R", "mapbox.R"))
#mb_access_token(token, install = TRUE)
#mb_geocode("Pittsburgh Pennsylvania United States")
data_list = fromJSON(rawToChar(res$content))

print("converted to json")

data = bind_rows(data_list$StudyFieldsResponse$StudyFields) %>% 
  mutate(Condition = map_chr(Condition, str_c, collapse=" "),
         Keyword = map_chr(Keyword, str_c, collapse=" ")) %>%
  filter(OverallStatus=="Recruiting",
         str_detect(Condition, "Progressive", negate = T),
         str_detect(Condition, "Dementia", negate = T),
         str_detect(Condition, "Aphasia") | str_detect(Keyword, "Aphasia")) %>%
  unnest(everything(),  keep_empty = T) %>%
  #filter(str_detect(LocationCountry, "United States")) %>%
  unite(remove = F, location, OrgFullName, LocationCity, LocationState, LocationCountry, sep = " ") %>%
  rowwise() %>%
  mutate(clinicaltrialsgov=1, Remote = "no")

print("cleaned data")

add_manual = manual %>%
  select(NCTId, BriefTitle, location, ResponsiblePartyInvestigatorFullName, StartDate, OrgFullName, LocationCity, LocationState, Remote)

print("added manual")

data2 = bind_rows(data, add_manual)

print("bind rows")

data2 = bind_rows(data, add_manual) %>%
  mutate(geo = list(mb_geocode(location, access_token = token)),
         lon = geo[1],
         lat = geo[2],
         date=lubridate::mdy(StartDate)) %>%
  select(-geo)

print("did mapbox stuff successfully")


write.csv(data2, file = here("data", "clinical_trials_clean.csv"))
print("Saved data")

res = GET("https://clinicaltrials.gov/api/query/study_fields?expr=aphasia+AND+AREA%5BOverallStatus%5DRecruiting&fields=BriefTitle%2C+Condition%2C+NCTId%2C+OrgFullName%2C+OverallStatus%2C+BriefSummary%2C+DetailedDescription%2C+Keyword%2C+StudyType%2C+EligibilityCriteria%2C+HealthyVolunteers%2C+MinimumAge%2C+Gender%2C+LocationCity%2C+LocationState%2C+ResponsiblePartyInvestigatorFullName%2C+CentralContactEmail%2C+CentralContactPhone%2C+CentralContactName%2C+LocationCountry&min_rnk=1&max_rnk=500&fmt=json")

data_list = fromJSON(rawToChar(res$content), flatten = T, simplifyVector =T)

print("v2 retrieved")

data_listcols = bind_rows(data_list$StudyFieldsResponse$StudyFields) %>% 
  mutate(Condition = map_chr(Condition, str_c, collapse=" "),
         Keyword = map_chr(Keyword, str_c, collapse=" ")) %>%
  #mutate(across(!starts_with("Central"), map_chr, str_c, collapse = " ")) %>%
  filter(OverallStatus=="Recruiting",
         str_detect(Condition, "Progressive", negate = T),
         str_detect(Condition, "Dementia", negate = T),
         str_detect(Condition, "Aphasia") | str_detect(Keyword, "Aphasia"))

# Have to split the data up 

contact <- data_listcols %>%
  select(starts_with("Central"), NCTId) %>%
  unnest(everything(),  keep_empty = T)

contact$clinicaltrialsgov = 1

contact <- bind_rows(contact, manual[,c("NCTId", "CentralContactEMail", "CentralContactPhone", "CentralContactName", "clinicaltrialsgov")])
  

print("v2 cleaned")

location <- data_listcols %>%
  select(starts_with("Location"), NCTId) %>%
  unnest(everything(),  keep_empty = T) %>%
  unite(remove = F, location, LocationCity, LocationState, sep = ", ", na.rm = T)  %>%
  group_by(NCTId) %>%
  summarize(cities = paste(location, collapse = "; "),
            countries = paste(unique(LocationCountry), collapse = ", "))
location$clinicaltrialsgov = 1

manual_location = manual %>%
  select(NCTId, cities = location, countries = country, clinicaltrialsgov)

location <- bind_rows(location, manual_location)

study_info <- data_listcols %>%
  select(Rank:Gender, ResponsiblePartyInvestigatorFullName) %>%
  unnest(everything(), keep_empty = T)

study_info[study_info==""] <- NA
study_info$clinicaltrialsgov = 1

manual_study_info = manual %>%
  select(NCTId, BriefTitle, flyer, clinicaltrialsgov, location, ResponsiblePartyInvestigatorFullName, StartDate, OrgFullName, LocationCity, LocationState)

study_info = bind_rows(study_info, manual_study_info)

write_rds(contact, file = here("data", "contact.rds"))
write_rds(location, file = here("data", "location.rds"))
write_rds(study_info, file = here("data", "study_info.rds"))

data_DT = data2 %>%
  select(BriefTitle, date, ResponsiblePartyInvestigatorFullName, NCTId, OrgFullName, Remote)

write_rds(data_DT, file = here("data", "data_dt.rds"))

print("v2 written")
