source(here::here("data-raw", "data_pins.R"))
source(here::here("data-raw", "rvu_functions.R"))

x <- download_rvu_zip_links(years = 2009)
x

# y <- download_rvu_zip_links(urls = x$error)
# res <- c(x$success, c(y))

new <- parse_rvu_zip_links(x)
new$description

# new$description <- stringr::str_squish(new$description)
# new$year <- vctrs::vec_fill_missing(new$year)
# new$date_start[2] <- as.Date("2011-01-01")

links <- add_zip_link(new)

pin_update(
  links,
  name = "rvu_zip_links",
  title = "RVU Zip File Links",
  description = "RVU Zip File Links from CMS.gov"
)
