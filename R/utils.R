#' Make a date object
#'
#' @param y `<integer>` year
#' @param m `<integer>` month, default is `1L`
#' @param d `<integer>` day, default is `1L`
#' @param ... additional arguments passed to `clock::date_build()`
#'
#' @returns `<Date>` date object
#'
#' @examples
#' make_date(2015:2025)
#' make_date(2010, 6, 1)
#' @export
make_date <- function(y, m = 1L, d = 1L, ...) {
  clock::date_build(
    year = y,
    month = m,
    day = d,
    ...,
    invalid = "previous"
  )
}
