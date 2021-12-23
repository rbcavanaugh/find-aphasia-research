setwd("~/random_rprojects/find-aphasia-research")

library(here)

here()

source(here("R", "get_data.R"))

Sys.sleep(5)

Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

rmarkdown::render_site(encoding = 'UTF-8')

library(gert)

git_add(".")
git_commit("weekly update")
git_push(remote = "origin", repo = ".")
