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
  url <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"
  path <- withr::local_tempfile()
  curl::curl_download(url, path, quiet = FALSE)
  x <- brio::read_lines(path)

  html <- trimws(x) |>
    grep("pfs-relative-value-files", x = _, value = TRUE, fixed = TRUE) |>
    grep(
      "<script type=|<link rel=|drupal-link-system-path=",
      x = _,
      value = TRUE,
      perl = TRUE,
      invert = TRUE
    ) |>
    gsub('"|^<a href=', "", x = _, perl = TRUE) |>
    gsub("</a>", "", x = _, fixed = TRUE) |>
    trimws(x = _) |>
    strsplit(x = _, ">", fixed = TRUE)

  fastplyr::new_tbl(
    yr = strtoi(substring(
      gsub("^RVU|^PRREV", "", purrr::map_chr(html, 2)),
      1L,
      2L
    )),
    year = strtoi(paste0("20", yr)),
    file = purrr::map_chr(html, 2),
    url = paste0("https://www.cms.gov", purrr::map_chr(html, 1))
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
