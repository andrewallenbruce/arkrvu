#' RVU Information Tables
#'
#' @param years `<int>` RVU source file year
#'
#' @param dos `<Date>` Date of Service, in the form YYYY-MM-DD
#'
#' @name link_tables
#'
#' @returns `<tibble>` containing RVU information
#'
#' @examples
#' rvu_link_table()
#' rvu_zip_links()
#' conversion_factor("2023-03-03")
#' conversion_factor(make_date(2018:2025))
#' conversion_factor()
NULL

#' @rdname link_tables
#' @export
rvu_link_table <- function(years) {
  if (missing(years)) {
    return(get_pin("rvu_link_table"))
  }

  collapse::sbt(get_pin("rvu_link_table"), year %iin% years)
}

#' @rdname link_tables
#' @export
rvu_zip_links <- function(years) {
  if (missing(years)) {
    return(get_pin("rvu_zip_links"))
  }

  collapse::sbt(get_pin("rvu_zip_links"), year %iin% years)
}

#' @rdname link_tables
#' @export
conversion_factor <- function(dos) {
  if (missing(dos)) {
    return(arkrvu::conv_fct)
  }

  if (!collapse::is_date(dos)) {
    dos <- as.Date(dos)
  }

  arkrvu::conv_fct[
    ivs::iv_locate_between(
      dos,
      arkrvu::conv_fct$date_iv,
      no_match = "drop"
    )$haystack,
  ]
}
