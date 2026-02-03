#' RVU Lookup by Date of Service, HCPCS, and Place of Service
#'
#' @param dos `<date>` date of service; YYYY-MM-DD
#'
#' @param hcpcs `<chr>` HCPCS code or vector of HCPCS codes
#'
#' @param pos `<chr>` Place of Service indicator; `Facility` or `Non-Facility`
#'
#' @param ... additional arguments
#'
#' @returns `<tibble>` containing RVU values for specified parameters
#'
#' @examples
#' rvu_lookup(dos = "2024-03-31", hcpcs = "99215", pos = "Non-Facility")
#' rvu_lookup(dos = "2024-02-28", hcpcs = "99215", pos = "Facility")
#'
#' @export
rvu_lookup <- function(dos, hcpcs, pos, ...) {
  if (missing(dos)) {
    cli::cli_abort("Argument {.arg dos} is required.")
  }

  if (!collapse::is_date(dos)) {
    dos <- as.Date(dos)
  }

  x <- switch(
    as.character(clock::get_year(dos)),
    "2024" = get_pin("pprrvu_2024") |>
      collapse::sbt(source_file %!=% "rvu24a_jan"),
    "2023" = get_pin("pprrvu_2023"),
    "2022" = get_pin("pprrvu_2022")
  )

  if (!missing(hcpcs)) {
    x <- collapse::ss(x, cheapr::which_(x$hcpcs == hcpcs))
  }

  if (!missing(pos)) {
    # Remove POS-specific columns
    collapse::gvr(
      x,
      switch(
        match.arg(pos, c("Facility", "Non-Facility")),
        "Facility" = "^non_fac",
        "Non-Facility" = "^facility_"
      )
    ) <- NULL
  }

  collapse::ss(
    x,
    cheapr::which_(
      data.table::between(
        dos,
        x$date_start,
        x$date_end
      )
    )
  )
}
