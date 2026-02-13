source(here::here("data-raw", "fns.R"))

x <- raw_source(2024, "pprrvu")$rvu24a_jan |>
  collapse::mtt(
    glob_days = glob_(glob_days) |> cheapr::as_factor(),
    diagnostic_imaging_family_indicator = diag_(
      diagnostic_imaging_family_indicator
    ) |>
      cheapr::as_factor(),
    pctc_ind = to_na(pctc_ind) |> cheapr::as_factor(),
    mult_proc = to_na(mult_proc) |> cheapr::as_factor(),
    bilat_surg = to_na(bilat_surg) |> cheapr::as_factor(),
    asst_surg = to_na(asst_surg) |> cheapr::as_factor(),
    co_surg = to_na(co_surg) |> cheapr::as_factor(),
    team_surg = to_na(team_surg) |> cheapr::as_factor(),
    non_fac_indicator = bin_(non_fac_indicator) |> cheapr::as_factor(),
    facility_indicator = bin_(facility_indicator) |> cheapr::as_factor(),
    not_used_for_medicare_payment = bin_(not_used_for_medicare_payment) |>
      cheapr::as_factor(),
    has_op = (pre_op + intra_op + post_op) |> cheapr::as_factor(),
    has_rvu = cheapr::if_else_(
      (non_facility_total + facility_total) > 0L,
      1L,
      0L
    ) |>
      cheapr::as_factor()
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
    has_rvu,
    ind_non = non_fac_indicator,
    ind_fac = facility_indicator,
    pctc = pctc_ind,
    glob = glob_days,
    mult = mult_proc,
    op_pre = pre_op,
    op_intra = intra_op,
    op_post = post_op,
    has_op,
    surg_bilat = bilat_surg,
    surg_asst = asst_surg,
    surg_co = co_surg,
    surg_team = team_surg,
    endo = endo_base,
    diag = diagnostic_imaging_family_indicator,
    cf = conv_factor
  ) |>
  classify_hcpcs()

cheapr::sset_row(x, x$has_rvu == 1L) |>
  fastplyr::as_tbl() |>
  collapse::fcount(level, section) |>
  collapse::roworder(-N)


cheapr::sset_row(x, x$has_rvu == 0L) |>
  fastplyr::as_tbl() |>
  collapse::fcount(level, section) |>
  collapse::roworder(-N)

ov <- cheapr::overview(x)

ov$numeric |>
  fastplyr::as_tbl() |>
  collapse::slt(
    column = col,
    unique = n_unique,
    mean,
    p0,
    p25,
    p75,
    p100,
    sd,
    hist
  )

ov$categorical |>
  fastplyr::as_tbl() |>
  collapse::slt(column = col, missing = n_missing, unique = n_unique, min, max)


saw_names <- c(
  "level",
  "section",
  "mod",
  "stat",
  "not_med",
  "ind_non",
  "ind_fac",
  "pctc",
  "glob",
  "mult",
  "endo",
  "diag",
  "surg_bilat",
  "surg_asst",
  "surg_co",
  "surg_team",
  "has_rvu",
  "has_op"
)

saw <- x |>
  hacksaw::count_split(
    level,
    section,
    mod,
    stat,
    not_med,
    ind_non,
    ind_fac,
    pctc,
    glob,
    mult,
    endo,
    diag,
    surg_bilat,
    surg_asst,
    surg_co,
    surg_team,
    has_rvu,
    has_op
  ) |>
  purrr::set_names(saw_names) |>
  purrr::map(function(x) {
    collapse::rnm(x, "value", cols = 1) |>
      collapse::mtt(value = as.character(value))
  }) |>
  purrr::list_rbind(names_to = "column") |>
  collapse::sbt(!cheapr::is_na(value))

cols <- c("has_op", "not_med", "ind_non", "ind_fac", "endo", "diag")

saw <- collapse::rowbind(
  collapse::sbt(saw, column != "endo"),
  collapse::sbt(saw, column == "endo") |>
    collapse::fgroup_by(column) |>
    collapse::fsummarise(n = sum(n)) |>
    collapse::mtt(value = "1")
) |>
  # collapse::fcount(column, w = n, add = TRUE) |>
  collapse::mtt(P = n / 18499L) |>
  # collapse::sbt(
  #   !(column == "has_rvu" & value != 0) &
  #     !(column %in% cols & value == "0")
  # ) |>
  print(n = Inf)

collapse::sbt(
  saw,
  column %iin% c("has_rvu", cols)
) |>
  collapse::roworder(-n) |>
  collapse::rowbind(
    collapse::sbt(
      saw,
      column %!iin%
        c("has_rvu", cols)
    )
  ) |>
  collapse::mtt(
    desc = cheapr::case(
      column == "stat" ~ recode_status(value),
      column == "mod" ~ recode_mod(value),
      column == "pctc" ~ recode_pctc(value),
      column == "glob" ~ recode_glob(value),
      column == "mult" ~ recode_mult(value),
      column == "surg_bilat" ~ recode_bilat(value),
      column == "surg_asst" ~ recode_asst(value),
      column == "surg_co" ~ recode_cosurg(value),
      column == "surg_team" ~ recode_team(value),
      .default = NA_character_
    )
  ) |>
  gt::gt(groupname_col = "column", row_group_as_column = TRUE) |>
  gt::tab_header(title = "2024 RVU Overview") |>
  gt::fmt_integer(columns = "n") |>
  gt::fmt_percent(columns = "P", decimals = 0) |>
  gt::cols_label(
    value = "Category",
    n = "Count",
    desc = "Description",
  ) |>
  gt::opt_table_font(
    font = list(
      gt::google_font(name = "IBM Plex Sans"),
      "Helvetica",
      "Arial",
      "sans-serif"
    )
  ) |>
  gt::data_color(
    columns = n,
    rows = column == "hcpcs_section",
    fn = scales::col_numeric(
      palette = "Greens",
      domain = c(0, 6000),
      na.color = "gray"
    )
  ) |>
  gt::data_color(
    columns = n,
    rows = column == "stat",
    fn = scales::col_numeric(
      palette = "Blues",
      domain = c(8, 8975),
      na.color = "gray"
    )
  ) |>
  gt::opt_vertical_padding(scale = 0.65) |>
  gt::sub_missing(missing_text = "-")
