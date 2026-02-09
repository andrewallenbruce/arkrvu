source(here::here("data-raw", "data_pins.R"))
source(here::here("data-raw", "rvu_functions.R"))

x <- download_rvu_zip_links(2014)
x

new <- parse_rvu_zip_links(x)
new

# new$year <- vctrs::vec_fill_missing(new$year)
# new$date_start[4] <- as.Date("2016-10-01")

links <- add_zip_link(new)

pin_update(
  links,
  name = "rvu_zip_links",
  title = "RVU Zip File Links",
  description = "RVU Zip File Links from CMS.gov"
)
