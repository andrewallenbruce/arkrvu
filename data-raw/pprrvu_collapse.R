source(here::here("data-raw", "data_pins.R"))

x <- raw_source(2024, "pprrvu")$rvu24a_jan |>
  collapse::mtt(
    non_fac_indicator = cheapr::if_else_(
      cheapr::is_na(non_fac_indicator),
      0L,
      1L
    ),
    facility_indicator = cheapr::if_else_(
      cheapr::is_na(facility_indicator),
      0L,
      1L
    ),
    not_used_for_medicare_payment = cheapr::if_else_(
      cheapr::is_na(not_used_for_medicare_payment),
      0L,
      1L
    ),
    tot_op = pre_op + intra_op + post_op,
    tot_rvu = non_facility_total + facility_total
  ) |>
  collapse::slt(
    hcpcs,
    mod,
    desc = description,
    stat = status_code,
    not_med = not_used_for_medicare_payment,
    rvu_wk = work_rvu,
    rvu_pe_non = non_fac_pe_rvu,
    rvu_pe_fac = facility_pe_rvu,
    rvu_mp = mp_rvu,
    tot_non = non_facility_total,
    tot_fac = facility_total,
    tot_rvu,
    ind_non = non_fac_indicator,
    ind_fac = facility_indicator,
    pctc = pctc_ind,
    glob = glob_days,
    mult = mult_proc,
    op_pre = pre_op,
    op_intra = intra_op,
    op_post = post_op,
    op_tot = tot_op,
    surg_bilat = bilat_surg,
    surg_asst = asst_surg,
    surg_co = co_surg,
    surg_team = team_surg,
    endo = endo_base,
    cf = conv_factor,
    podp = physician_supervision_of_diagnostic_procedures
  )

saw_names <- c(
  "mod",
  "stat",
  "not_med",
  "ind_non",
  "ind_fac",
  "pctc",
  'glob',
  "mult",
  "endo",
  'podp',
  "surg_bilat",
  "surg_asst",
  "surg_co",
  "surg_team",
  "tot_rvu",
  "op_tot"
)

# hacksaw::count_split(
#   x,
#   fuimus::create_vec(colnames(x), enclose = c("c(", ")")) |>
#     rlang::parse_expr() |>
#     rlang::eval_tidy()
# )

saw <- x |>
  hacksaw::count_split(
    mod,
    stat,
    not_med,
    ind_non,
    ind_fac,
    pctc,
    glob,
    mult,
    endo,
    podp,
    surg_bilat,
    surg_asst,
    surg_co,
    surg_team,
    tot_rvu,
    op_tot
  ) |>
  purrr::set_names(saw_names) |>
  purrr::map(function(x) {
    collapse::rnm(x, "value", cols = 1) |>
      collapse::mtt(value = as.character(value))
  }) |>
  purrr::list_rbind(names_to = "column")

collapse::rowbind(
  collapse::sbt(saw, column != "tot_rvu"),
  collapse::sbt(saw, column == "tot_rvu" & value == "0")
) |>
  collapse::fcount(column, w = n, add = TRUE) |>
  print(n = Inf)


pprrvu$rvu23a_jan <- x$rvu24a_jan |>
  dplyr::mutate(
    date_start = make_date(year),
    date_end = make_date(year, 3L, 31L),
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

list_pins()
