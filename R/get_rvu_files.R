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
