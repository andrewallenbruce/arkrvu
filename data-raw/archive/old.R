
#' Parallelized [get_pprrvu()]
#'
#' @param df `<tibble>` containing dos, hcpcs, pos
#'
#' @param ... Pass arguments to [get_pprrvu()].
#'
#' @returns `<tibble>` containing pprrvu source file
#'
#' @autoglobal
#'
#' @importFrom zeallot %<-%
#'
#' @noRd
get_pprrvu2_ <- function(df, dos, code, pos) {
  df <- dplyr::reframe(
    df,
    dos = clock::as_date(dos),
    year = as.character(clock::get_year(dos)),
    code = hcpcs,
    pos = pos
  )

  # df <- dplyr::transmute(
  #   df,
  #   dos = clock::as_date({{ dos }}),
  #   year = as.character(clock::get_year({{ dos }})),
  #   code = {{ code }},
  #   pos = {{ pos }})

  # pp <- list(
  #   '2024' = collapse::fsubset(
  #     get_pin("pprrvu_2024"),
  #     source_file %!=% "rvu24a_jan"
  #   ),
  #   '2023' = get_pin("pprrvu_2023"),
  #   '2022' = get_pin("pprrvu_2022")
  # )
  #
  # c(dos, year, code, pos) %<-% as.list(df[1:1, ])

  # pprrvu_vec <- \(dos, year, code, pos, pp = pp[[year]], ...) {
  #   if (pos == "Non-Facility") {
  #     file <- vctrs::vec_slice(pp, pp$hcpcs == code)
  # file <- collapse::fsubset(
  #   pp,
  #   hcpcs %==% code,
  #   date_start,
  #   date_end,
  #   hcpcs,
  #   mod,
  #   description,
  #   wrvu = work_rvu,
  #   prvu = non_fac_pe_rvu,
  #   mrvu = mp_rvu,
  #   trvu = non_facility_total,
  #   cf = conv_factor,
  #   pctc = pctc_ind,
  #   glob = glob_days,
  #   mult = mult_proc
  # )
}

# if (pos == "Facility") {
#   file <- collapse::fsubset(
#     pp,
#     hcpcs %==% code,
#     date_start,
#     date_end,
#     hcpcs,
#     mod,
#     description,
#     wrvu = work_rvu,
#     prvu = facility_pe_rvu,
#     mrvu = mp_rvu,
#     trvu = facility_total,
#     cf = conv_factor,
#     pctc = pctc_ind,
#     glob = glob_days,
#     mult = mult_proc
#   )
# }

#   if (vctrs::vec_is_empty(file)) {
#     file <- dplyr::tibble(
#       date_start = as.Date(dos),
#       date_end = as.Date(dos),
#       hcpcs = hcpcs,
#       mod = NA_character_,
#       description = NA_character_,
#       wrvu = NA_real_,
#       prvu = NA_real_,
#       mrvu = NA_real_,
#       trvu = NA_real_,
#       cf = NA_real_,
#       pctc = NA_character_,
#       glob = NA_character_,
#       mult = NA_character_
#     )
#   }
#   file <- collapse::fsubset(
#     file,
#     data.table::between(
#       dos,
#       date_start,
#       date_end
#     )
#   )
#   return(file)
# }

purrr::pmap(
  .l = as.list(df[1:10, ]),
  .f = pprrvu_vec
)

tictoc::tic()

future::plan(
  future::multisession(
    workers = parallelly::availableCores()
  )
)

x <- furrr::future_pmap_dfr(
  .l = as.list(df[1:10, ]),
  .f = pprrvu_vec,
  # ...,
  .options = furrr::furrr_options(seed = NULL)
)

future::plan("sequential")

tictoc::toc()

return(x)
}


#' Parallelized [get_pprrvu()]
#'
#' @param df `<tibble>` containing dos, hcpcs, pos
#' @param ... Pass arguments to [get_pprrvu()].
#' @returns `<tibble>` containing pprrvu source file
#' @noRd
get_pprrvu_ <- function(df, ...) {
  # tictoc::tic()
  #
  # future::plan(
  #   future::multisession(
  #     workers = parallelly::availableCores()
  #   )
  # )
  # x <- furrr::future_pmap_dfr(
  #   .l = as.list(df),
  #   .f = get_pprrvu,
  #   ...,
  #   .options = furrr::furrr_options(seed = NULL)
  # )
  #
  # future::plan("sequential")
  #
  # tictoc::toc()
  # return(x)
}
