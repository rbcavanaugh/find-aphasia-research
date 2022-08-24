
library(tidyverse)
library(magrittr)


manual = read_csv(here("data", "manual-submissions.csv"))


head(manual)

new = tibble(
  NCTId                                    = "manual6",
  BriefTitle                               = "Assessment of anomia: Improving efficiency and utility using item response theory",
  country                                  = "United States",
  flyer                                    = "steel2022",
  location                                 = "Portland, OR",
  ResponsiblePartyInvestigatorFullName     = "Gerasimos Fergadiotis",
  StartDate                                = "08/31/2020",
  OrgFullName                              = "Portland State University",
  LocationCity                             = "Portland",
  LocationState                            = "OR",
  Remote                                   = "no", # no, online, or travel provided
  CentralContactEMail                      = "aphasialab@pdx.edu",
  CentralContactPhone                      = "503-725-3275",
  CentralContactName                       = "Stacey Steel"
)

manual %<>% add_row(new)

write.csv(manual, here("data", "manual-submissions.csv"))
