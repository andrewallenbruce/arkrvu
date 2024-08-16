source(here::here("data-raw", "pins_functions.R"))

year   <- 2022
pprrvu <- get_source(year, "pprrvu")

pprrvu$rvu22a_jan <- pprrvu$rvu22a_jan |>
  dplyr::mutate(
    date_start = clock::date_build(year, 1, 1, invalid = "previous"),
    date_end = clock::date_build(year, 3, 31, invalid = "previous"),
    .before = 1
    )

pprrvu$rvu22b_apr <- pprrvu$rvu22b_apr |>
  dplyr::mutate(
    date_start = clock::date_build(year, 4, 1, invalid = "previous"),
    date_end = clock::date_build(year, 6, 30, invalid = "previous"),
    .before = 1
  )

pprrvu$rvu22c_jul <- pprrvu$rvu22c_jul |>
  dplyr::mutate(
    date_start = clock::date_build(year, 7, 1, invalid = "previous"),
    date_end = clock::date_build(year, 9, 30, invalid = "previous"),
    .before = 1
  )

pprrvu$rvu22d_oct <- pprrvu$rvu22d_oct |>
  dplyr::mutate(
    date_start = clock::date_build(year, 7, 1, invalid = "previous"),
    date_end = clock::date_build(year, 9, 30, invalid = "previous"),
    .before = 1
  )

pprrvu <- pprrvu |>
  purrr::list_rbind(names_to = "source_file")

#--- PINS ####
pin_update(
  pprrvu,
  name = stringr::str_glue("pprrvu_{year}") |> as.character(),
  title = stringr::str_glue("PPRRVU {year}") |> as.character()
)
