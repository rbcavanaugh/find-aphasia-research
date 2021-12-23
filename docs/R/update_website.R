setwd("~/random_rprojects/find-aphasia-research")

library(here)

here()

source(here("R", "get_data.R"))

Sys.sleep(5)

Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

rmarkdown::render_site(encoding = 'UTF-8')

library(gert)

system("cd ~/random_rprojects/find-aphasia-research")
system("git add .")
system("git commit -m 'weekly update'")
system("git push")
# git_add(".")
# git_commit("weekly update")
# git_push(remote = "origin")
