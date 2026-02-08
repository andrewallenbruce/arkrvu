#' RVU File Download Links
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' download_links()
#'
#' @export
download_links <- function() {
  get_pin("rvu_link_table")
}

#' RVU Zip File Download Links
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' zip_links()
#'
#' @export
zip_links <- function() {
  get_pin("rvu_zip_links")
}

#' Download RVU Link Table
#' @returns `<tibble>` containing year, file, and url of RVU source files
#' @examplesIf rlang::is_interactive()
#' download_table()
#' @keywords internal
#' @export
download_table <- function() {
  x <- rvest::read_html(
    "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"
  )

  table <- rvest::html_table(x) |>
    _[[1]] |>
    rlang::set_names(c("year", "file")) |>
    collapse::mtt(
      year = strtoi(stringr::str_extract(year, "[12]{1}[0-9]{3}")),
      file = stringr::str_replace(file, stringr::fixed("File Name\n"), "") |>
        stringr::str_squish()
    )

  urls <- rvest::html_elements(x, css = "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset("pfs-relative-value-files[/-]")

  fastplyr::f_bind_cols(
    table,
    url = paste0("https://www.cms.gov", urls)
  )
}

#' Download RVU Zip File Links
#' @param years `<int>` years of RVU source files
#' @returns `<tibble>` containing year, file, and url of RVU source files
#' @examplesIf rlang::is_interactive()
#' download_zip_links(years = 2024)
#' @keywords internal
#' @export
download_zip_links <- function(years) {
  if (missing(years)) {
    cli::cli_abort("Argument {.arg years} is required.")
  }

  url <- collapse::sbt(download_links(), year %in% years) |> _$url

  results <- purrr::map(
    url,
    rvest::read_html,
    .progress = stringr::str_glue(
      "Downloading {length(url)} Pages"
    )
  )

  return(results)
}
