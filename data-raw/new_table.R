# https://www.cms.gov/sample-pfs-searches
# https://www.cms.gov/pfs-quick-reference-search-guide

collapse::join(
  get_pin("rvu_link_table") |> collapse::frename(url_link = url),
  get_pin("rvu_zip_links") |> collapse::frename(url_zip = url)
) |>
  collapse::colorder(
    year,
    file,
    date_start,
    date_end,
    description,
    url_link,
    url_zip
  ) |>
  print(n = Inf)


rvu_24 <- tibble::tibble(
  file = c("RVU24A", "RVU24AR", "RVU24B", "RVU24C"),
  source = c("rvu24a_jan", "rvu24ar_jan", "rvu24b_apr", "rvu24c_jul"),
  date_start = as.Date(c(
    "2024-01-01",
    "2024-03-09",
    "2024-04-01",
    "2024-07-01"
  )),
  date_end = as.Date(c("2024-03-08", "2024-03-31", "2024-06-30", "2024-09-30")),
  date_iv = ivs::iv(date_start, date_end + 1L),
  n_days = clock::date_count_between(
    ivs::iv_start(date_iv), # date_start,
    ivs::iv_end(date_iv) - 1L, # date_end,
    "day"
  ),
  n_obs = c(18499L, 18499L, 18534L, 18664L),
)

rvu_23 <- tibble::tibble(
  file = c("RVU23A", "RVU23B", "RVU23C", "RVU23D"),
  source = c("rvu23a_jan", "rvu23b_apr", "rvu23c_jul", "rvu23d_oct"),
  date_start = as.Date(c(
    "2023-01-01",
    "2023-04-01",
    "2023-07-01",
    "2023-10-01"
  )),
  date_end = as.Date(c("2023-03-31", "2023-06-30", "2023-09-30", "2023-12-31")),
  date_iv = ivs::iv(date_start, date_end + 1L),
  n_days = clock::date_count_between(
    ivs::iv_start(date_iv),
    ivs::iv_end(date_iv) - 1L,
    "day"
  ),
  n_obs = c(18010L, 18037L, 18132L, 18168L)
)

rvu_22 <- tibble::tibble(
  file = c("RVU22A", "RVU22B", "RVU22C", "RVU22D"),
  source = c("rvu22a_jan", "rvu22b_apr", "rvu22c_jul", "rvu22d_oct"),
  date_start = as.Date(c(
    "2022-01-01",
    "2022-04-01",
    "2022-07-01",
    "2022-10-01"
  )),
  date_end = as.Date(c("2022-03-31", "2022-06-30", "2022-09-30", "2022-12-31")),
  date_iv = ivs::iv(date_start, date_end + 1L),
  n_days = clock::date_count_between(
    ivs::iv_start(date_iv),
    ivs::iv_end(date_iv) - 1L,
    "day"
  ),
  n_obs = c(17600L, 17630L, 17695L, 17726L),
)

vctrs::vec_rbind(
  rvu_24,
  rvu_23,
  rvu_22
) |>
  fastplyr::f_full_join(download_links()) |>
  fastplyr::f_select(
    # yr,
    year,
    file,
    # source,
    date_start,
    date_end,
    date_iv,
    # n_days,
    n_obs,
    url
  ) |>
  fastplyr::f_arrange(year, date_start, file, .descending = TRUE) |>
  print(n = Inf)

get_pin("pprrvu_2022") |>
  collapse::fcount(source_file, date_start, date_end) |>
  constructive::construct()

get_pin("pprrvu_2022") |>
  collapse::ss(j = c(1, 4:34)) |>
  collapse::funique(cols = -1) |>
  collapse::sbt(hcpcs %!in_% dupes) |>
  collapse::rsplit(~source_file)

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
