torvu <- readr::read_csv(
  "data-raw/archive/torvu.csv",
  col_types = readr::cols(
    dos = readr::col_date(format = "%Y-%m-%d"),
    hcpcs = readr::col_character()
  )
)

torvu |>
  collapse::mtt(year = clock::get_year(dos)) |>
  tidyr::nest(hcpcs = c(dos, hcpcs)) |>
  collapse::rsplit(~year)
