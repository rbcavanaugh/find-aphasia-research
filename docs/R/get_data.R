
library(httr)
library(jsonlite)
library(tidyverse)
library(here)
library(mapboxapi)

res = GET("https://clinicaltrials.gov/api/query/study_fields?expr=aphasia+AND+AREA%5BOverallStatus%5DRecruiting&fields=BriefTitle%2C+Condition%2C+StartDate%2C+NCTId%2C+OrgFullName%2C+OverallStatus%2C+BriefSummary%2C+DetailedDescription%2C+Keyword%2C+StudyType%2C+EligibilityCriteria%2C+HealthyVolunteers%2C+MinimumAge%2C+Gender%2C+LocationCity%2C+LocationZip%2C+LocationState%2C+ResponsiblePartyInvestigatorFullName%2C+LocationCountry&min_rnk=1&max_rnk=500&fmt=json")


#source(here("R", "mapbox.R"))
#mb_access_token(token, install = TRUE)
#mb_geocode("Pittsburgh Pennsylvania United States")
data_list = fromJSON(rawToChar(res$content))

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
  mutate(geo = list(mb_geocode(location)),
         lon = geo[1],
         lat = geo[2]) %>%
  select(-geo)



write.csv(data, file = here("data", "clinical_trials_clean.csv"))


res = GET("https://clinicaltrials.gov/api/query/study_fields?expr=aphasia+AND+AREA%5BOverallStatus%5DRecruiting&fields=BriefTitle%2C+Condition%2C+NCTId%2C+OrgFullName%2C+OverallStatus%2C+BriefSummary%2C+DetailedDescription%2C+Keyword%2C+StudyType%2C+EligibilityCriteria%2C+HealthyVolunteers%2C+MinimumAge%2C+Gender%2C+LocationCity%2C+LocationState%2C+ResponsiblePartyInvestigatorFullName%2C+CentralContactEmail%2C+CentralContactPhone%2C+CentralContactName%2C+LocationCountry&min_rnk=1&max_rnk=500&fmt=json")

data_list = fromJSON(rawToChar(res$content), flatten = T, simplifyVector =T)

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
  
location <- data_listcols %>%
  select(starts_with("Location"), NCTId) %>%
  unnest(everything(),  keep_empty = T) %>%
  unite(remove = F, location, LocationCity, LocationState, sep = ", ", na.rm = T)  %>%
  group_by(NCTId) %>%
  summarize(cities = paste(location, collapse = "; "),
            countries = paste(unique(LocationCountry), collapse = ", "))

study_info <- data_listcols %>%
  select(Rank:Gender, ResponsiblePartyInvestigatorFullName) %>%
  unnest(everything(), keep_empty = T)

study_info[study_info==""] <- NA

write_rds(contact, file = here("data", "contact.rds"))
write_rds(location, file = here("data", "location.rds"))
write_rds(study_info, file = here("data", "study_info.rds"))


# 
# to_google <- study_info %>%
#   select(BriefTitle, BriefSummary) %>%
#   mutate(SpanishSummary= paste0('=GOOGLETRANSLATE(A',row_number()+1, ',"en","es")'))
# 
# library(googlesheets4)
# 
# sheet_write(to_google, sheet = "scaley-honeybee")
