download_zip_links <- function(years) {
  if (missing(years)) {
    cli::cli_abort("Argument {.arg years} is required.")
  }

  url <- collapse::sbt(download_links(), year %in% years) |> _$url

  path <- withr::local_tempfile()
  curl::multi_download(url, path, resume = TRUE)
  z <- trimws(brio::read_lines(path))

  z <- cheapr::sset(z, cheapr::which_(nzchar(z))) |>
    grep("files/zip", x = _, fixed = TRUE, value = TRUE) |>
    gsub('<li class=\"field__item\"><a href=\"', "", x = _, fixed = TRUE) |>
    gsub("</a></li>", "", x = _, fixed = TRUE) |>
    gsub("\"|\\+|hreflang", "", x = _, perl = TRUE) |>
    gsub("=en>", "", x = _, fixed = TRUE) |>
    gsub(" - Updated ", " ", x = _, fixed = TRUE) |>
    strsplit(x = _, " ", fixed = TRUE)

  fastplyr::new_tbl(
    link = paste0("https://www.cms.gov", purrr::map_chr(z, 1)),
    file = purrr::map_chr(z, 2),
    updated = purrr::map_chr(z, 3) |> as.Date(format = "%m/%d/%Y")
  ) |>
    collapse::colorder(file, updated, link)
}
