# Corrected PPRRVU 2024 date ranges
pprrvu_2024 <- get_pin("pprrvu_2024") |>
  collapse::mtt(
    date_start = cheapr::if_else_(
      source_file == "rvu24ar_jan",
      clock::date_build(2024, 3, 9),
      date_start
    ),
    date_end = cheapr::if_else_(
      source_file == "rvu24a_jan",
      clock::date_build(2024, 3, 8),
      date_end
    ),
    date_iv = ivs::iv(date_start, date_end + 1L)
  ) |>
  collapse::colorder(source_file, date_start, date_end, date_iv)

pin_update(
  pprrvu_2024,
  name = "pprrvu_2024",
  title = "PPRRVU Data for 2024",
  description = "PPR RVU data for the year 2024 with corrected date ranges."
)
