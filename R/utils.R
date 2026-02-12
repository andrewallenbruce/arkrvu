#' @noRd
grepl_ <- function(x, pattern) {
  grepl(pattern, x, ignore.case = TRUE, perl = TRUE)
}

# @inheritParams rlang::args_error_context
#' @noRd
check_nchars <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (any(nchar(x) != 5L, na.rm = TRUE)) {
    cli::cli_abort(
      "{.arg {arg}} must be 5 characters long.",
      arg = arg,
      call = call
    )
  }
}

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

#' Mount [pins][pins::pins-package] board
#' @param source `<chr>` `"local"` or `"remote"`
#' @returns `<pins_board_folder>` or `<pins_board_url>`
#' @keywords internal
#' @export
mount_board <- function(source = c("local", "remote")) {
  switch(
    match.arg(source),
    local = pins::board_folder(
      fs::path_package("extdata/pins", package = "arkrvu")
    ),
    remote = pins::board_url(paste0(
      "https://raw.githubusercontent.com/",
      "andrewallenbruce/arkrvu/master/inst/extdata/pins/"
    ))
  )
}

#' List [pins][pins::pins-package]
#' @param ... arguments to pass to [mount_board()]
#' @returns `<chr>` vector of named pins
#' @keywords internal
#' @export
list_pins <- function(...) {
  board <- mount_board(...)

  pins::pin_list(board)
}

#' Load [pins][pins::pins-package]
#' @param pin `<chr>` pin name, see [list_pins()]
#' @param ... additional arguments passed to [mount_board()]
#' @returns `<tibble>` containing pinned dataset
#' @keywords internal
#' @export
get_pin <- function(pin, ...) {
  board <- mount_board(...)
  pin <- rlang::arg_match0(pin, list_pins())
  pins::pin_read(board, pin)
}

#' Create/Update [pins][pins::pins-package]
#' @param data data to pin
#' @param pin `<chr>` pin name, see [list_pins()]
#' @param ... additional arguments passed to [pins::pin_write()]
#' @returns nothing, called for side effects
#' @noRd
update_pin <- function(data, pin, title, ...) {
  board <- mount_board()
  board |>
    pins::pin_write(
      x = data,
      name = pin,
      type = "rds",
      title = title,
      ...
    )
  board |> pins::write_board_manifest()
}

#' Delete internal [pins][pins::pins-package]
#' @param pin `<chr>` pin name, see [list_pins()]
#' @returns nothing, called for side effects
#' @noRd
delete_pins <- function(pin) {
  board <- mount_board()
  pins::pin_delete(board, names = pin)
}
