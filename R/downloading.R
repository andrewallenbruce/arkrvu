#' Download RVU Link Table
#'
#' Downloads the table of RVU source file links from the CMS website. Used
#' internally to populate and update the `rvu_link_table` dataset.
#'
#' @returns `<tibble>` containing year, file, and url of RVU source files
#'
#' @examplesIf FALSE
#' download_rvu_link_table()
#'
#' @keywords internal
#'
#' @export
download_rvu_link_table <- function() {
  x <- rvest::read_html(
    "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"
  )

  table <- rvest::html_table(x) |>
    purrr::pluck(1) |>
    rlang::set_names(c("year", "file")) |>
    collapse::mtt(
      year = strtoi(stringr::str_extract(
        year,
        stringr::regex("[12]{1}[0-9]{3}")
      )),
      file = stringr::str_replace(file, stringr::fixed("File Name\n"), "") |>
        stringr::str_squish()
    )

  urls <- rvest::html_elements(x, css = "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset("pfs-relative-value-files[/-]")

  if (nrow(table) != length(urls)) {
    cli::cli_warn(
      "Length of {.var urls} {.pkg ({length(urls)})} does not match number of {.var table} rows {.pkg ({nrow(table)})}."
    )
  }

  fastplyr::f_bind_cols(
    table,
    url = paste0("https://www.cms.gov", urls)
  )
}

#' Download RVU Zip File Link Table
#'
#' Downloads the table of RVU source zip file links from the CMS website. Used
#' internally to populate and update the `rvu_zip_links` dataset.
#'
#' @param years `<int>` year(s) of RVU source file, available in `rvu_link_table()`
#'
#' @returns `<tibble>` containing year, file, and url of RVU source files
#'
#' @examplesIf FALSE
#' download_rvu_zip_links(years = 2024)
#'
#' @keywords internal
#'
#' @export
download_rvu_zip_links <- function(years) {
  if (missing(years)) {
    cli::cli_abort("Argument {.arg years} is required.")
  }

  links <- rvu_link_table()

  if (any(!years %in% collapse::funique(links$year))) {
    cli::cli_abort(
      "One or more {.arg years} not found in {.fn rvu_link_table}."
    )
  }

  url <- collapse::sbt(links, year %in% years) |> _$url

  results <- purrr::map(
    url,
    rvest::read_html,
    .progress = stringr::str_glue(
      "Downloading {length(url)} Pages"
    )
  )
  return(results)
}
