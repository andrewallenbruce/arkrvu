#' Get RVU Source File
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

#' Get Conversion Factors by Effective Date
#'
#' @param dos `<Date>` date of service
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' get_conversion_factor(dos = as.Date("2023-03-03"))
#'
#' get_conversion_factor() |>
#'    print(n = 30)
#'
#' @autoglobal
#'
#' @export
get_conversion_factor <- function(dos = NULL) {
  dt <- \(y, m = 1L, d = 1L, ...) {
    clock::date_build(
      year = y,
      month = m,
      day = d,
      ...,
      invalid = "previous"
    )
  }

  cf_df <- fastplyr::new_tbl(
    date_start = c(
      dt(1992L),
      dt(1993L),
      dt(1994L),
      dt(1995L),
      dt(1996L),
      dt(1997L),
      dt(1998L),
      dt(1999L),
      dt(2000L),
      dt(2001L),
      dt(2002L),
      dt(2003L),
      dt(2004L),
      dt(2005L),
      dt(2006L),
      dt(2007L),
      dt(2008L),
      dt(2009L),
      dt(2010L), #dt(2010, 5, 31),
      dt(2010L, 6L, 1L), #dt(2010, 12, 31),
      dt(2011L),
      dt(2012L),
      dt(2013L),
      dt(2014L),
      dt(2015L), #dt(2015, 6, 30),
      dt(2015L, 7, 1), #dt(2015, 12, 31),
      dt(2016),
      dt(2017),
      dt(2018),
      dt(2019),
      dt(2020),
      dt(2021),
      dt(2022),
      dt(2023),
      dt(2024), #dt(2024, 3, 8),
      dt(2024, 3, 9) #dt(2024, 12, 31)
    ),
    cf = c(
      31.0010,
      NA_real_,
      NA_real_,
      NA_real_,
      NA_real_,
      NA_real_,
      36.6873,
      34.7315,
      36.6137,
      38.2581,
      36.1992,
      36.7856,
      37.3374,
      37.8975,
      37.8975,
      37.8975,
      38.0870,
      36.0666,
      36.0791,
      36.8729,
      33.9764,
      34.0376,
      34.0230,
      35.8228,
      35.7547,
      35.9335,
      35.8043,
      35.8887,
      35.9996,
      36.0391,
      36.0896,
      34.8931,
      34.6062,
      33.8872,
      32.7442,
      33.2875
    )
  )

  cf_df = cf_df |>
    collapse::roworder(date_start) |>
    collapse::mtt(
      date_end = cheapr::lag_(date_start, -1L) - 1L,
      date_end = cheapr::val_match(
        date_start,
        dt(2010) ~ dt(2010, 5, 31),
        dt(2015) ~ dt(2015, 6, 30),
        dt(2024) ~ dt(2024, 3, 8),
        dt(2010, 6, 1) ~ dt(2010, 12, 31),
        dt(2015, 7, 1) ~ dt(2015, 12, 31),
        dt(2024, 3, 9) ~ dt(2024, 12, 31),
        .default = date_end
      ),
      date_interval = ivs::iv(date_start, date_end),
      cf_chg_abs = cf - cheapr::lag_(cf),
      cf_chg_rel = (cf - cheapr::lag_(cf)) / cheapr::lag_(cf)
    )

  if (!is.null(dos)) {
    cf_df <- cf_df |>
      dplyr::rowwise() |>
      dplyr::filter(
        dplyr::between(
          as.Date(dos),
          date_start,
          date_end
        )
      ) |>
      dplyr::ungroup()
  }
  return(cf_df)
}

#' Download/Update RVU Link Table
#'
#' @param update_pin `<lgl>` update `"rvu_link_table"` pin; default is `FALSE`
#'
#' @returns RVU Link Table
#'
#' @autoglobal
#'
#' @keywords internal
#'
#' @export
download_link_table <- function(update_pin = FALSE) {
  url_land <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

  tictoc::tic("Downloaded RVU File Page")
  html_land <- rvest::read_html(url_land)
  tictoc::toc()

  rvu_table <- rvest::html_table(html_land) |>
    purrr::pluck(1) |>
    dplyr::reframe(
      year = as.integer(stringr::str_remove_all(Name, "\\D")),
      file_html = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP")
    )

  rvu_urls <- rvest::html_elements(html_land, "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset(
      stringr::regex(
        paste(
          "/medicare/payment/fee-schedules/physician/pfs-relative-value-files/",
          "/medicare/medicare-fee-service-payment/physicianfeesched/pfs-relative-value-files/",
          "/medicaremedicare-fee-service-paymentphysicianfeeschedpfs-relative-value-files/",
          "/medicare/medicare-fee-for-service-payment/physicianfeesched/pfs-relative-value-files-items/",
          sep = "|"
        )
      )
    )

  link_table <- dplyr::bind_cols(
    rvu_table,
    dplyr::tibble(
      file_url = strex::str_after_last(rvu_urls, "/"),
      link_url = paste0("https://www.cms.gov", rvu_urls)
    )
  )

  if (update_pin) {
    pin_update <- \(x, name, title) {
      board <- pins::board_folder(here::here("inst/extdata/pins"))
      board |> pins::pin_write(x, name = name, title = title, type = "qs")
      board |> pins::write_board_manifest()
    }

    pin_update(
      link_table,
      name = "rvu_link_table",
      title = "RVU Download Links"
    )
  }
  return(link_table)
}
