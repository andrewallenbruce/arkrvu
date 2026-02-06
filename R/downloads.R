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

#' Download RVU Link Table
#' @returns `<tibble>` containing year, file, and url of RVU source files
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
    yr = as.integer(substring(
      gsub("^RVU|^PRREV", "", purrr::map_chr(html, 2)),
      1L,
      2L
    )),
    year = as.integer(paste0("20", yr)),
    file = purrr::map_chr(html, 2),
    url = paste0("https://www.cms.gov", purrr::map_chr(html, 1))
  )
}
# pin_update(x, name = "rvu_link_table", title = "RVU File Download Links", description = "RVU File Download Links from CMS.gov")
