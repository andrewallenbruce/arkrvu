#' Get RVU Source File
#'
#' @param year `<int>` year of rvu source file; default is `2020`
#'
#' @param source `<chr>` rvu source file (`pprvu`, `oppscap`, `gpci`, `locco`, `anes`)
#'
#' @returns `<list>` of tibbles containing rvu source files
#'
#' @examples
#' get_source(2024, "pprrvu")
#'
#' get_source(2024, "gpci")
#'
#' @autoglobal
#'
#' @export
get_source <- function(year, source) {

  year   <- as.character(year)
  year   <- match.arg(year, as.character(2020:2024))
  source <- match.arg(source, c("pprrvu", "oppscap", "gpci", "locco", "anes"))

  file <- switch(
    year,
    '2024' = get_pin("rvu_source_2024"),
    '2023' = get_pin("rvu_source_2023"),
    '2022' = get_pin("rvu_source_2022"),
    '2021' = get_pin("rvu_source_2021"),
    '2020' = get_pin("rvu_source_2020")
         )

  switch(
    source,
    pprrvu  = file$pprrvu,
    oppscap = file$oppscap,
    gpci    = file$gpci,
    locco   = file$locco,
    anes    = file$anes
  )
}

#' Get PPRRVU File by Year
#'
#' @param dos `<date>` date of service; YYYY-MM-DD
#'
#' @param hcpcs `<chr>` hcpcs code
#'
#' @param pos `<chr>` place of service; `Facility` or `Non-Facility`
#'
#' @returns `<tibble>` containing pprrvu source file
#'
#' @examples
#' get_pprrvu(dos = "2024-03-31", hcpcs = "99213", pos = "Non-Facility")
#' get_pprrvu(dos = "2024-02-28", hcpcs = "99213", pos = "Facility")
#'
#' @autoglobal
#'
#' @export
get_pprrvu <- function(dos, hcpcs, pos) {

  dos  <- as.Date(dos)
  year <- as.character(clock::get_year(dos))
  pos  <- match.arg(pos, c("Facility", "Non-Facility"))
  code <- stringfish::convert_to_sf(hcpcs)

  pp <- list(
    '2024' = collapse::fsubset(get_pin("pprrvu_2024"), source_file %!=% "rvu24a_jan"),
    '2023' = get_pin("pprrvu_2023"),
    '2022' = get_pin("pprrvu_2022")
  )

  if (pos == "Non-Facility") {
    file <- collapse::fsubset(
      pp[[year]],
      hcpcs %==% code,
      date_start,
      date_end,
      hcpcs,
      mod,
      description,
      wrvu = work_rvu,
      prvu = non_fac_pe_rvu,
      mrvu = mp_rvu,
      trvu = non_facility_total,
      cf = conv_factor,
      pctc = pctc_ind,
      glob = glob_days,
      mult = mult_proc
    )
  }

  if (pos == "Facility") {
    file <- collapse::fsubset(
      pp[[year]],
      hcpcs %==% code,
      date_start,
      date_end,
      hcpcs,
      mod,
      description,
      wrvu = work_rvu,
      prvu = facility_pe_rvu,
      mrvu = mp_rvu,
      trvu = facility_total,
      cf = conv_factor,
      pctc = pctc_ind,
      glob = glob_days,
      mult = mult_proc
    )
  }

  if (vctrs::vec_is_empty(file)) {
    file <- dplyr::tibble(
        date_start  = as.Date(dos),
        date_end    = as.Date(dos),
        hcpcs       = hcpcs,
        mod         = NA_character_,
        description = NA_character_,
        wrvu        = NA_real_,
        prvu        = NA_real_,
        mrvu        = NA_real_,
        trvu        = NA_real_,
        cf          = NA_real_,
        pctc        = NA_character_,
        glob        = NA_character_,
        mult        = NA_character_
      )
    }
  file <- collapse::fsubset(file, data.table::between(dos, date_start, date_end))
  return(file)
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

  cf_df <- dplyr::tibble(
    date_start = c(
      clock::date_build(2024, 1, 1, invalid = "previous"),
      clock::date_build(2024, 3, 9, invalid = "previous"),
      # clock::date_build(2024, 12, 31, invalid = "previous"),
      clock::date_build(2023, 1, 1, invalid = "previous"),
      clock::date_build(2022, 1, 1, invalid = "previous"),
      clock::date_build(2021, 1, 1, invalid = "previous"),
      clock::date_build(2020, 1, 1, invalid = "previous"),
      clock::date_build(2019, 1, 1, invalid = "previous"),
      clock::date_build(2018, 1, 1, invalid = "previous"),
      clock::date_build(2017, 1, 1, invalid = "previous"),
      clock::date_build(2016, 1, 1, invalid = "previous"),
      clock::date_build(2015, 1, 1, invalid = "previous"),
      clock::date_build(2015, 4, 1, invalid = "previous"),
      clock::date_build(2014, 1, 1, invalid = "previous"),
      clock::date_build(2013, 1, 1, invalid = "previous"),
      clock::date_build(2012, 1, 1, invalid = "previous"),
      clock::date_build(2011, 1, 1, invalid = "previous"),
      clock::date_build(2010, 1, 1, invalid = "previous"),
      clock::date_build(2010, 6, 1, invalid = "previous"),
      clock::date_build(2009, 1, 1, invalid = "previous"),
      clock::date_build(2008, 1, 1, invalid = "previous"),
      clock::date_build(2008, 7, 1, invalid = "previous"),
      clock::date_build(2007, 1, 1, invalid = "previous"),
      clock::date_build(2006, 1, 1, invalid = "previous"),
      clock::date_build(2005, 1, 1, invalid = "previous"),
      clock::date_build(2004, 1, 1, invalid = "previous"),
      clock::date_build(2003, 3, 1, invalid = "previous"),
      clock::date_build(2002, 1, 1, invalid = "previous"),
      clock::date_build(2001, 1, 1, invalid = "previous"),
      clock::date_build(2000, 1, 1, invalid = "previous")
    ),
    cf = c(
      32.7442,
      33.2875,
      33.8872,
      34.6062,
      34.8931,
      36.0896,
      36.0391,
      35.9996,
      35.8887,
      35.8043,
      35.7547,
      28.1872,
      35.8228,
      34.0230,
      34.0376,
      33.9764,
      36.0791,
      36.8729,
      36.0666,
      38.087,
      38.087,
      37.8975,
      37.8975,
      37.8975,
      37.3374,
      36.7856,
      36.1992,
      38.2581,
      36.6137
    )
  ) |>
    dplyr::arrange(date_start) |>
    dplyr::reframe(
      date_start,
      date_end = dplyr::lead(date_start) - 1,
      date_interval = ivs::iv(date_start, date_end),
      cf,
      cf_chg_abs = cf - dplyr::lag(cf),
      cf_chg_rel = (cf - dplyr::lag(cf)) / dplyr::lag(cf)
    )

  if (!is.null(dos)) {
    cf_df <- cf_df |>
      dplyr::rowwise() |>
      dplyr::filter(
        dplyr::between(
          as.Date(dos),
          date_start,
          date_end)
        ) |>
      dplyr::ungroup()
  }
  return(cf_df)
}

#' Download/update RVU Link Table
#'
#' @param update_pin `<lgl>` update pin; default is `FALSE`
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
    dplyr::reframe(year = as.integer(stringr::str_remove_all(Name, "\\D")),
                   file_html = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP"))

  rvu_urls <- rvest::html_elements(html_land, "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset(stringr::regex(
      paste(
        "/medicare/payment/fee-schedules/physician/pfs-relative-value-files/",
        "/medicare/medicare-fee-service-payment/physicianfeesched/pfs-relative-value-files/",
        "/medicaremedicare-fee-service-paymentphysicianfeeschedpfs-relative-value-files/",
        "/medicare/medicare-fee-for-service-payment/physicianfeesched/pfs-relative-value-files-items/",
        sep = "|"
      )))

  link_table <- dplyr::bind_cols(
    rvu_table,
    dplyr::tibble(
      file_url = strex::str_after_last(rvu_urls, "/"),
      link_url = paste0("https://www.cms.gov", rvu_urls)
    ))

  if (update_pin) {
    pin_update <- \(x, name, title) {
      board <- pins::board_folder(here::here("inst/extdata/pins"))
      board |> pins::pin_write(x, name = name, title = title, type = "qs")
      board |> pins::write_board_manifest()
    }
    pin_update(
      link_table,
      name = "rvu_link_table",
      title = "RVU Download Links")
  }
  return(link_table)
}
