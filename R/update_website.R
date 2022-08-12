#setwd("~/github-repos/find-aphasia-research")

library(mapboxapi)
# Comment out for local push
MAPBOX_SECRET <- Sys.getenv("MAILBOX")
mb_access_token(as.character(MAPBOX_SECRET), install = FALSE)

library(here)

here()

source(here("R", "get_data.R"))

Sys.sleep(5)

Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

rmarkdown::render_site(encoding = 'UTF-8')
