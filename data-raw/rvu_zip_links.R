source(here::here("data-raw", "data_pins.R"))
source(here::here("data-raw", "rvu_functions.R"))

x <- download_rvu_zip_links(2010)
x

y <- purrr::map(
  x$error,
  try_read_html,
  .progress = stringr::str_glue(
    "Downloading {length(x$error)} Pages"
  )
)
# x <- c(x$success, c(y))

new <- parse_rvu_zip_links(x)
new


# new$description <- stringr::str_squish(new$description)
new$year <- vctrs::vec_fill_missing(new$year)
new$date_start[2] <- as.Date("2011-01-01")

links <- add_zip_link(x)

pin_update(
  links,
  name = "rvu_zip_links",
  title = "RVU Zip File Links",
  description = "RVU Zip File Links from CMS.gov"
)

# rvu_link_table() |> _$year |> collapse::funique()

x <- z[[3]]

x <- purrr::map(z, \(x) {
  fastplyr::new_tbl(
    url = stringr::str_c(
      "https://www.cms.gov",
      rvest::html_elements(x, css = "a") |>
        rvest::html_attr("href") |>
        collapse::funique() |>
        stringr::str_subset(".zip") |>
        stringr::str_remove(stringr::fixed(" /apps/ama/license.asp?file="))
    ) |>
      stringr::str_subset(stringr::fixed("/RVU")),
    info = rvest::html_elements(x, css = ".field") |>
      rvest::html_text2() |>
      collapse::funique() |>
      stringr::str_subset("Dynamic List", negate = TRUE) |>
      stringr::str_subset("File Name|Description|File Size|Downloads") |>
      stringr::str_replace_all("\\n", " ")
  ) |>
    collapse::mtt(
      col_name = cheapr::case(
        stringr::str_detect(info, "File Name") ~ "file",
        stringr::str_detect(info, "Description") ~ "description",
        stringr::str_detect(info, "File Size") ~ "size",
        stringr::str_detect(info, "Downloads") ~ "updated",
        .default = NA_character_
      ),
      info = stringr::str_remove_all(
        info,
        "File Name |Description |File Size |Downloads "
      )
    ) |>
    collapse::pivot(
      names = "col_name",
      values = "info",
      how = "wider"
    )
}) |>
  collapse::rowbind(fill = TRUE)
