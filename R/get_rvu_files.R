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

#' RVU Source File
#'
#' @param year `<int>` year of rvu source file; default is `2020`
#' @param source `<chr>` rvu source file (`pprvu`, `oppscap`, `gpci`, `locco`, `anes`)
#' @returns `<list>` of tibbles containing rvu source files
#' @examples
#' get_source(2024, "pprrvu")
#' get_source(2024, "gpci")
#' @export
get_source <- function(year, source) {
  file <- switch(
    match.arg(as.character(year), as.character(2020:2024)),
    "2024" = get_pin("rvu_source_2024"),
    "2023" = get_pin("rvu_source_2023"),
    "2022" = get_pin("rvu_source_2022"),
    "2021" = get_pin("rvu_source_2021"),
    "2020" = get_pin("rvu_source_2020")
  )

  switch(
    match.arg(source, c("pprrvu", "oppscap", "gpci", "locco", "anes")),
    pprrvu = file$pprrvu,
    oppscap = file$oppscap,
    gpci = file$gpci,
    locco = file$locco,
    anes = file$anes
  )
}

#' PPRRVU File by Year
#'
#' @param dos `<date>` date of service; YYYY-MM-DD
#' @param hcpcs `<chr>` hcpcs code
#' @param pos `<chr>` place of service; `Facility` or `Non-Facility`
#' @param ... additional arguments
#' @returns `<tibble>` containing PPRRVU source file
#' @examples
#' get_pprrvu(dos = "2024-03-31", hcpcs = "99213", pos = "Non-Facility")
#' get_pprrvu(dos = "2024-02-28", hcpcs = "99213", pos = "Facility")
#' @autoglobal
#' @export
get_pprrvu <- function(dos, hcpcs, pos, ...) {
  dos <- as.Date(dos)

  year <- as.character(clock::get_year(dos))

  x <- switch(
    year,
    "2024" = collapse::sbt(
      get_pin("pprrvu_2024"),
      source_file %!=% "rvu24a_jan"
    ),
    "2023" = get_pin("pprrvu_2023"),
    "2022" = get_pin("pprrvu_2022")
  )

  x <- collapse::ss(x, cheapr::which_(x$hcpcs == hcpcs))
  collapse::ss(
    x,
    cheapr::which_(data.table::between(dos, x$date_start, x$date_end))
  )
}
