source(here::here("data-raw", "pins_functions.R"))

year   <- 2023
pprrvu <- get_source(year, "pprrvu")
make_date <- \(year, month = 1L, day = 1L) clock::date_build(year, month, day, invalid = "previous")

pprrvu$rvu23a_jan <- pprrvu$rvu23a_jan |>
  dplyr::mutate(
    date_start = clock::date_build(year, 1, 1, invalid = "previous"),
    date_end = clock::date_build(year, 3, 31, invalid = "previous"),
    .before = 1
    )

pprrvu$rvu23b_apr <- pprrvu$rvu23b_apr |>
  dplyr::mutate(
    date_start = clock::date_build(year, 4, 1, invalid = "previous"),
    date_end = clock::date_build(year, 6, 30, invalid = "previous"),
    .before = 1
  )

pprrvu$rvu23c_jul <- pprrvu$rvu23c_jul |>
  dplyr::mutate(
    date_start = clock::date_build(year, 7, 1, invalid = "previous"),
    date_end = clock::date_build(year, 9, 30, invalid = "previous"),
    .before = 1
  )

pprrvu$rvu23d_oct <- pprrvu$rvu23d_oct |>
  dplyr::mutate(
    date_start = clock::date_build(year, 10, 1, invalid = "previous"),
    date_end = clock::date_build(year, 12, 31, invalid = "previous"),
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
