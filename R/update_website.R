library(here)

source(here("R", "get_data.R"))

Sys.sleep(5)

rmarkdown::render_site(encoding = 'UTF-8')

