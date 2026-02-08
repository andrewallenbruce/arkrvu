source(here::here("data-raw", "data_pins.R"))
source(here::here("data-raw", "rvu_functions.R"))

x <- download_zip_links(2019)
x

zip_19 <- process_zip_links(x)

rvu_zip_links <- vctrs::vec_rbind(
  get_pin("rvu_zip_links"),
  zip_19
) |>
  collapse::roworder(year, file) |>
  collapse::mtt(
    date_end = cheapr::if_else_(
      is.na(date_end),
      cheapr::lag_(date_start, -1L) - 1L,
      date_end
    )
  ) |>
  collapse::colorder(
    year,
    file,
    date_start,
    date_end,
    description,
    size,
    url
  )

pin_update(
  rvu_zip_links,
  name = "rvu_zip_links",
  title = "RVU Zip File Links",
  description = "RVU Zip File Links from CMS.gov"
)
