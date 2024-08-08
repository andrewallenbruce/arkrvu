#' Get RVU Source File
#'
#' @param year `<int>` year
#'
#' @param source `<chr>` rvu source file (`pprvu`, `oppscap`, `gpci`, `locco`, `anes`)
#'
#' @returns `<list>` of tibbles containing rvu source files
#'
#' @examples
#' get_source(2024, "pprrvu")
#'
#' get_source(2024, "gpci")
#'
#' @autoglobal
#'
#' @export
get_source <- function(year, source) {

  year   <- as.character(year)
  year   <- match.arg(year, as.character(2021:2024))
  source <- match.arg(source, c("pprrvu", "oppscap", "gpci", "locco", "anes"))

  file <- switch(
    year,
    '2024' = get_pin("rvu_source_2024"),
    '2023' = get_pin("rvu_source_2023"),
    '2022' = get_pin("rvu_source_2022"),
    '2021' = get_pin("rvu_source_2021")
         )

  switch(
    source,
    pprrvu  = file$pprrvu,
    oppscap = file$oppscap,
    gpci    = file$gpci,
    locco   = file$locco,
    anes    = file$anes
  )
}


#' Get RVU Link Table
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' get_link_table()
#'
#' @autoglobal
#'
#' @export
get_link_table <- function() {
  get_pin("rvu_link_table")
}

#' Get Conversion Factors by Effective Date
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' get_conversion_factor()
#'
#' @autoglobal
#'
#' @export
get_conversion_factor <- function() {

  dplyr::tibble(
    date_effective = as.Date(c(
      "2024-01-01",
      "2024-03-09",
      "2023-01-01",
      "2022-01-01",
      "2021-01-01",
      "2020-01-01",
      "2019-01-01",
      "2018-01-01",
      "2017-01-01",
      "2016-01-01",
      "2015-01-01",
      "2015-04-01",
      "2014-01-01",
      "2013-01-01",
      "2012-01-01",
      "2011-01-01",
      "2010-01-01",
      "2010-06-01",
      "2009-01-01",
      "2008-01-01",
      "2008-07-01",
      "2007-01-01",
      "2006-01-01",
      "2005-01-01",
      "2004-01-01",
      "2003-03-01", # Medicare physician/practitioner claims for services in January and February, 2003 were paid at the 2002 Physician Fee Schedule rates. The 2003 rates were effective March 1, 2003 through December 31, 2003.
      "2002-01-01",
      "2001-01-01",
      "2000-01-01"
      )
    ),
    year = as.integer(lubridate::year(date_effective)),
    conversion_factor = c(
      32.7442,
      33.2875,
      33.8872,
      34.6062,
      34.8931,
      36.0896,
      36.0391,
      35.9996,
      35.8887,
      35.8043,
      35.7547,
      28.1872,
      35.8228,
      34.0230,
      34.0376,
      33.9764,
      36.0791,
      36.8729,
      36.0666,
      38.087, # 0.5 percent update, retroactive to July 1, 2008
      38.087,
      37.8975,
      37.8975,
      37.8975,
      37.3374,
      36.7856,
      36.1992,
      38.2581,
      36.6137
      )
  ) |>
    dplyr::arrange(date_effective) |>
    dplyr::mutate(
      abs_change = (conversion_factor - dplyr::lag(conversion_factor)))
}

#' Download/update RVU Link Table
#'
#' @param update_pin `<lgl>` update pin; default is `FALSE`
#'
#' @returns RVU Link Table
#'
#' @autoglobal
#'
#' @keywords internal
#'
#' @export
download_link_table <- function(update_pin = FALSE) {

  url_land <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

  tictoc::tic("Downloaded RVU File Page")
  html_land <- rvest::read_html(url_land)
  tictoc::toc()

  rvu_table <- rvest::html_table(html_land) |>
    purrr::pluck(1) |>
    dplyr::reframe(year = as.integer(stringr::str_remove_all(Name, "\\D")),
                   file_html = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP"))

  rvu_urls <- rvest::html_elements(html_land, "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset(stringr::regex(
      paste(
        "/medicare/payment/fee-schedules/physician/pfs-relative-value-files/",
        "/medicare/medicare-fee-service-payment/physicianfeesched/pfs-relative-value-files/",
        "/medicaremedicare-fee-service-paymentphysicianfeeschedpfs-relative-value-files/",
        "/medicare/medicare-fee-for-service-payment/physicianfeesched/pfs-relative-value-files-items/",
        sep = "|"
      )))

  link_table <- dplyr::bind_cols(
    rvu_table,
    dplyr::tibble(
      file_url = strex::str_after_last(rvu_urls, "/"),
      link_url = paste0("https://www.cms.gov", rvu_urls)
    ))

  if (update_pin) {
    pin_update <- \(x, name, title) {
      board <- pins::board_folder(here::here("inst/extdata/pins"))
      board |> pins::pin_write(x, name = name, title = title, type = "qs")
      board |> pins::write_board_manifest()
    }
    pin_update(
      link_table,
      name = "rvu_link_table",
      title = "RVU Download Links")
  }
  return(link_table)
}
