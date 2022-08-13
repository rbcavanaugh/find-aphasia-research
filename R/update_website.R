#setwd("~/github-repos/find-aphasia-research")

library(mapboxapi)
# Comment out for local push
token = Sys.getenv("MAPBOX")
print(nchar(token))
mb_access_token(token, install = FALSE)

library(here)

here()

source(here("R", "get_data.R"))

print("get data successful!!")

Sys.sleep(5)

Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

rmarkdown::render_site(encoding = 'UTF-8')
