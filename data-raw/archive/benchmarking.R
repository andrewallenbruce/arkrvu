"96130"
"96131"
"96136"
"96137"

ex <- readr::read_csv(
  here::here("data-raw/torvu.csv"),
  col_types = readr::cols(
    dos = readr::col_date(format = ""),
    hcpcs = readr::col_character(),
    pos = readr::col_character()
  ))

n <- 1

rlang::as_list(ex[n:20, ])

ex[n:20, ]

get_pprrvu(
  dos = ex[n, ]$dos,
  hcpcs = ex[n, ]$hcpcs,
  pos = ex[n, ]$pos
)

get_pprrvu_(df = ex[n:20, ])

dos <- ex[n,]$dos
hcpcs <- ex[n,]$hcpcs
pos <- ex[n,]$pos


tictoc::tic()
future::plan(future::multisession(workers = 4))
results <- furrr::future_map_dfr(
  1:700,
  ~get_pprrvu(
    dos = ex[.x, ]$dos,
    hcpcs = ex[.x, ]$hcpcs,
    pos = ex[.x, ]$pos
  )
)
future::plan("sequential")
tictoc::toc()

# 770.93 sec elapsed
# 12.84883 min elapsed
#
# 39.62 sec elapsed
# 31.8 sec elapsed

#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
#   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
# 1 new           3.78m    3.78m   0.00440   49.05GB     1.33     1   302      3.78m
# 2 furrr        34.77s   34.77s   0.0288     6.37MB     0        1     0     34.77s

results |>
  fuimus::remove_quiet() |>
  vctrs::vec_cbind(ex) |>
  janitor::clean_names() |>
  dplyr::select(-hcpcs_14) |>
  dplyr::rename(hcpcs = hcpcs_3) |>
  readr::write_csv(
    "C:/Users/Andrew/Desktop/Repositories/acephale/posts/claims/data/results.csv"
    )

dos = "2024-03-31"
hcpcs = "99213"
pos = "Non-Facility"

file |>
  dplyr::rowwise() |>
  dplyr::filter(dplyr::between(dos, date_start, date_end)) |>
  dplyr::ungroup()

file |>
  dplyr::filter(purrr::pmap_lgl(list(dos, date_start, date_end), dplyr::between))


bench::mark(
  new = purrr::map_dfr(1:700, ~get_pprrvu(dos = ex[.x, ]$dos, hcpcs = ex[.x, ]$hcpcs, pos = ex[.x, ]$pos)),
  furr = {
    future::plan(future::multisession(workers = 4))
    furrr::future_map_dfr(
      1:700,
      ~get_pprrvu(
        dos = ex[.x, ]$dos,
        hcpcs = ex[.x, ]$hcpcs,
        pos = ex[.x, ]$pos
      )
    )
    future::plan("sequential")},
  check = FALSE
)
