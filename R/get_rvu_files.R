#' Get RVU Files
#'
#' @param source rvu source (link, zip, file, pprvu, oppscap, gpci, locco, anes)
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' get_source("link")
#'
#' get_source("zip")
#'
#' get_source("file")
#'
#' get_source("pprvu")
#'
#' get_source("gpci")
#'
#' @autoglobal
#'
#' @export
get_source <- function(source = c("link", "zip", "file", "pprvu", "oppscap", "gpci", "locco", "anes")) {

  source <- match.arg(source)

  switch(
    source,
    link    = get_pin("rvu_source_2024")$link_table,
    zip     = get_pin("rvu_source_2024")$zip_table,
    file    = get_pin("rvu_source_2024")$zip_list,
    pprvu   = get_pin("rvu_source_2024")$files$pprvu,
    oppscap = get_pin("rvu_source_2024")$files$oppscap,
    gpci    = get_pin("rvu_source_2024")$files$gpci,
    locco   = get_pin("rvu_source_2024")$files$locco,
    anes    = get_pin("rvu_source_2024")$files$anes
  )

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
      pct_change = (
        dplyr::lag(conversion_factor) - conversion_factor
        ) / conversion_factor
      )
}
