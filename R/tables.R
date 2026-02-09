#' RVU File Information Tables
#'
#' @param years `<int>` RVU source file year
#'
#' @name link_tables
#'
#' @returns `<tibble>` containing information about RVU source files
#'
#' @examples
#' rvu_link_table()
#'
#' rvu_zip_links()
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
