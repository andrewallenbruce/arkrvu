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
    paste0(
      "https://www.cms.gov/medicare/payment/",
      "fee-schedules/physician/pfs-relative-value-files"
    )
  )

  table <- rvest::html_table(x) |>
    purrr::pluck(1) |>
    rlang::set_names(c("year", "file")) |>
    collapse::mtt(
      year = strtoi(stringr::str_extract(
        year,
        stringr::regex("[12]{1}[0-9]{3}")
      )),
      file = stringr::str_squish(stringr::str_remove(
        file,
        stringr::fixed("File Name\n")
      ))
    )

  urls <- rvest::html_elements(x, css = "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset("pfs-relative-value-files[/-]")

  if (nrow(table) != length(urls)) {
    cli::cli_warn(
      paste(
        "Length of {.var urls} {.pkg ({length(urls)})} does not match",
        "number of {.var table} rows {.pkg ({nrow(table)})}."
      )
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
download_rvu_zip_links <- function(years, urls) {
  rlang::check_exclusive(years, urls)

  if (!missing(years)) {
    urls <- rvu_link_table(years)$url
  }

  try_read_html <- function(x) {
    rlang::try_fetch(
      rvest::read_html(x),
      error = function(cnd) x
    )
  }

  res <- purrr::map(
    urls,
    try_read_html,
    .progress = stringr::str_glue(
      "Downloading {length(urls)} Pages"
    )
  )

  urls <- purrr::discard(res, function(x) inherits(x, "xml_document")) |>
    unlist(use.names = FALSE)

  if (rlang::has_length(urls)) {
    cli::cli_warn("{.pkg {length(urls)}} {.emph url{?s}} errored.")
    return(
      list(
        success = purrr::keep(res, function(x) inherits(x, "xml_document")),
        error = urls
      )
    )
  }

  return(res)
}
