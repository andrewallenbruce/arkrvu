# https://www.cms.gov/sample-pfs-searches
# https://www.cms.gov/pfs-quick-reference-search-guide

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


download_links() |>
  # collapse::mtt()
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

get_pin("pprrvu_2022") |>
  collapse::fcount(source_file, date_start, date_end) |>
  constructive::construct()

d <- get_pin("pprrvu_2022") |> collapse::ss(j = c(4:34))

d$did <- vctrs::vec_duplicate_id(d)

vctrs::vec_slice(d, d$did == 2549) |> dplyr::glimpse()

dupes <- d[
  d$did |>
    vctrs::vec_count() |>
    tibble::as_tibble() |>
    dplyr::filter(count == 4) |>
    _$key,
] |>
  _$hcpcs

get_pin("pprrvu_2022") |>
  collapse::ss(j = c(1, 4:34)) |>
  collapse::funique(cols = -1) |>
  collapse::sbt(hcpcs %!in_% dupes) |>
  collapse::rsplit(~source_file)
