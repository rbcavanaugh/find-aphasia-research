
library(httr)
library(jsonlite)
library(tidyverse)
library(ggmap)
library(here)

res = GET("https://clinicaltrials.gov/api/query/study_fields?expr=aphasia+AND+AREA%5BOverallStatus%5DRecruiting&fields=BriefTitle%2C+Condition%2C+StartDate%2C+NCTId%2C+OrgFullName%2C+OverallStatus%2C+BriefSummary%2C+DetailedDescription%2C+Keyword%2C+StudyType%2C+EligibilityCriteria%2C+HealthyVolunteers%2C+MinimumAge%2C+Gender%2C+LocationCity%2C+LocationZip%2C+LocationState%2C+LocationCountry&min_rnk=1&max_rnk=500&fmt=json")

data_list = fromJSON(rawToChar(res$content))

data = bind_rows(data_list$StudyFieldsResponse$StudyFields) %>% 
  mutate(Condition = map_chr(Condition, str_c, collapse=" "),
         Keyword = map_chr(Keyword, str_c, collapse=" ")) %>%
  filter(OverallStatus=="Recruiting",
         str_detect(Condition, "Progressive", negate = T),
         str_detect(Condition, "Dementia", negate = T),
         str_detect(Condition, "Aphasia") | str_detect(Keyword, "Aphasia")) %>%
  unnest(everything(),  keep_empty = T) %>%
  filter(str_detect(LocationCountry, "United States")) %>%
  unite(remove = F, location, LocationCity, LocationState, LocationCountry, sep = " ") %>%
  mutate(geo = geocode(location)) %>%
  unnest(geo)

write.csv(data, file = here("data", "clinical_trials_clean.csv"))



