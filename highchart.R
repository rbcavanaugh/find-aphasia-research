library(highcharter)
library(here)
library(tidyverse)

data = read.csv(here("data", "clinical_trials_clean.csv"))%>%
  select(BriefTitle, Condition, StartDate, name = NCTId,
         OrgFullName, BriefSummary, DetailedDescription,
         Keyword, StudyType, EligibilityCriteria, HealthyVolunteers,
         MinimumAge, Gender, LocationCity, LocationState, lon, lat) %>%
  mutate(BriefTitle = gsub("[.]", "", x=BriefTitle),
         z=1,
         link=paste0("https://website.com/",name))

hcmap("countries/us/us-all", showInLegend = FALSE) %>%
  hc_add_series(
    data = data, 
    type = "mapbubble",
    name = "Studies", 
    minSize = "5%",
    maxSize = "5%",
    color = hex_to_rgba("darkgreen", alpha = 0.3),
    tooltip =list(
      pointFormat = "<a href='{point.link}'>{point.BriefTitle}</a>"
    )
)%>%
  hc_tooltip(
      style = list(pointerEvents ='auto')
  ) %>%
  hc_mapNavigation(enabled = TRUE)%>%
  hc_plotOptions(series=list(stickyTracking=T))
