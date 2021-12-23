library(here)

source(here("R", "get_data.R"))

Sys.sleep(5)

rmarkdown::render_site(encoding = 'UTF-8')

library(gert)

git_add(".")
git_commit("weekly update")
git_push()
