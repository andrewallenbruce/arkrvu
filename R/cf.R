#' Conversion Factor
#'
#' @param dos `<Date>` Date of Service, in the form YYYY-MM-DD; default is `NULL`
#'
#' @returns `tibble` containing conversion factors; if `dos` is provided, returns conversion factor for that date
#'
#' @examples
#' conversion_factor("2023-03-03")
#' conversion_factor(make_date(2018:2025))
#' conversion_factor()
#'
#' @export
conversion_factor <- function(dos = NULL) {
  if (is.null(dos)) {
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
