## code to prepare `conv_fct` dataset goes here
conv_fct <- tibble::tibble(
  date_start = c(
    make_date(1992:2024),
    make_date(2010L, 6L, 1L),
    make_date(2015L, 7L, 1L),
    make_date(2024L, 3L, 9L)
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

conv_fct <- conv_fct |>
  collapse::roworder(date_start) |>
  collapse::mtt(
    date_end = cheapr::lag_(date_start, -1L) - 1L,
    date_end = cheapr::val_match(
      date_start,
      make_date(2010L) ~ make_date(2010L, 5L, 31L),
      make_date(2015L) ~ make_date(2015L, 6L, 30L),
      make_date(2024L) ~ make_date(2024L, 3L, 8L),
      make_date(2010L, 6L, 1L) ~ make_date(2010L, 12L, 31L),
      make_date(2015L, 7L, 1L) ~ make_date(2015L, 12L, 31L),
      make_date(2024L, 3L, 9L) ~ make_date(2024L, 12L, 31L),
      .default = date_end
    ),
    date_iv = ivs::iv(date_start, date_end),
    cf = vctrs::vec_fill_missing(cf),
    chg_abs = cf - cheapr::lag_(cf),
    chg_rel = (cf - cheapr::lag_(cf)) / cheapr::lag_(cf)
  ) |>
  collapse::colorder(date_start, date_end, date_iv, cf, chg_abs, chg_rel)

usethis::use_data(conv_fct, overwrite = TRUE)
