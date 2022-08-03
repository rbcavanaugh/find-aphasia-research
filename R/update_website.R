setwd("~/github-repos/find-aphasia-research")

library(here)

here()

source(here("R", "get_data.R"))

Sys.sleep(5)

Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

rmarkdown::render_site(encoding = 'UTF-8')

