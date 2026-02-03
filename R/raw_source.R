#' RVU Raw Source Files
#'
#' @param year `<int>` year of RVU source file
#'
#' @param type `<chr>` RVU source file type, one of:
#'    - `pprrvu`: PPRRVU
#'    - `oppscap`: OPPSCAP
#'    - `gpci`: GPCI
#'    - `locco`: LOCCO
#'    - `anes`: ANESTHESIA
#'
#' @returns `<list>` of tibbles containing RVU source files
#'
#' @examples
#' raw_source(year = 2024, type = "pprrvu")
#' raw_source(year = 2023, type = "gpci")
#' raw_source(year = 2022)
#'
#' @export
raw_source <- function(year, type) {
  x <- switch(
    match.arg(as.character(year), as.character(2020:2024)),
    "2024" = get_pin("rvu_source_2024"),
    "2023" = get_pin("rvu_source_2023"),
    "2022" = get_pin("rvu_source_2022"),
    "2021" = get_pin("rvu_source_2021"),
    "2020" = get_pin("rvu_source_2020")
  )

  if (missing(type)) {
    cli::cli_inform("Returning all RVU source files for year {year}.")
    return(x)
  }

  switch(
    match.arg(type, c("pprrvu", "oppscap", "gpci", "locco", "anes")),
    pprrvu = x$pprrvu,
    oppscap = x$oppscap,
    gpci = x$gpci,
    locco = x$locco,
    anes = x$anes
  )
}
