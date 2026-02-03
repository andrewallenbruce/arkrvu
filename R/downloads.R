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
  tmp <- tempfile()
  curl::curl_download(url, tmp, quiet = FALSE)
  html <- brio::read_lines(tmp)
  unlink(tmp)

  html <- trimws(html)
  html <- grep("pfs-relative-value-files", html, value = TRUE, fixed = TRUE)
  html <- grep(
    "<script type=|<link rel=|drupal-link-system-path=",
    html,
    value = TRUE,
    perl = TRUE,
    invert = TRUE
  )
  html <- gsub('"|^<a href=|</a>$', "", html, perl = TRUE)
  html <- trimws(html)
  html <- strsplit(html, ">", fixed = TRUE)

  fastplyr::new_tbl(
    year = as.integer(paste0(
      "20",
      substring(gsub("^RVU|^PRREV", "", purrr::map_chr(html, 2)), 1L, 2L)
    )),
    file = purrr::map_chr(html, 2),
    url = paste0("https://www.cms.gov", purrr::map_chr(html, 1))
  )
  # pin_update(
  #   x,
  #   name = "rvu_link_table",
  #   title = "RVU File Download Links",
  #   description = "RVU File Download Links from CMS.gov"
  # )
}
