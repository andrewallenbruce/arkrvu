source(here::here("data-raw", "fns.R"))

x <- raw_source(2024, "pprrvu")$rvu24a_jan |>
  collapse::mtt(
    glob_days = glob_(glob_days),
    diagnostic_imaging_family_indicator = diag_(
      diagnostic_imaging_family_indicator
    ),
    pctc_ind = to_na(pctc_ind),
    mult_proc = to_na(mult_proc),
    bilat_surg = to_na(bilat_surg),
    asst_surg = to_na(asst_surg),
    co_surg = to_na(co_surg),
    team_surg = to_na(team_surg),
    non_fac_indicator = bin_(non_fac_indicator),
    facility_indicator = bin_(facility_indicator),
    not_used_for_medicare_payment = bin_(not_used_for_medicare_payment),
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
    tot_op,
    surg_bilat = bilat_surg,
    surg_asst = asst_surg,
    surg_co = co_surg,
    surg_team = team_surg,
    endo = endo_base,
    diag = diagnostic_imaging_family_indicator,
    cf = conv_factor
  ) |>
  classify_hcpcs()

saw_names <- c(
  "hcpcs_type",
  "hcpcs_section",
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
  "tot_rvu",
  "tot_op"
)

saw <- x |>
  hacksaw::count_split(
    hcpcs_type,
    hcpcs_section,
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
    tot_rvu,
    tot_op
  ) |>
  purrr::set_names(saw_names) |>
  purrr::map(function(x) {
    collapse::rnm(x, "value", cols = 1) |>
      collapse::mtt(value = as.character(value))
  }) |>
  purrr::list_rbind(names_to = "column") |>
  collapse::sbt(!cheapr::is_na(value))

cols <- c("tot_op", "not_med", "ind_non", "ind_fac", "endo", "diag")

saw <- collapse::rowbind(
  collapse::sbt(saw, column != "endo"),
  collapse::sbt(saw, column == "endo") |>
    collapse::fgroup_by(column) |>
    collapse::fsummarise(n = sum(n)) |>
    collapse::mtt(value = "1")
) |>
  # collapse::fcount(column, w = n, add = TRUE) |>
  collapse::mtt(P = n / 18499L) |>
  collapse::sbt(
    !(column == "tot_rvu" & value != 0) &
      !(column %in% cols & value == "0")
  ) |>
  print(n = Inf)

collapse::sbt(
  saw,
  column %iin% c("tot_rvu", cols)
) |>
  collapse::roworder(-n) |>
  collapse::rowbind(
    collapse::sbt(
      saw,
      column %!iin%
        c("tot_rvu", cols)
    )
  ) |>
  collapse::mtt(
    desc = cheapr::case(
      column == "stat" ~ recode_status(value),
      column == "mod" ~ recode_mod(value),
      column == "pctc" ~ recode_pctc(value),
      column == "glob" ~ recode_glob(value),
      # column == "mult" ~ recode_mult(value),
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
