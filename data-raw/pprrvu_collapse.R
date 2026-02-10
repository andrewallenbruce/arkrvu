source(here::here("data-raw", "data_pins.R"))

x <- raw_source(2024, "pprrvu")$rvu24a_jan |>
  collapse::mtt(
    glob_days = cheapr::val_match(
      glob_days,
      "000" ~ "0",
      "010" ~ "1",
      "090" ~ "9",
      "MMM" ~ "M",
      "XXX" ~ "X",
      "YYY" ~ "Y",
      "ZZZ" ~ "Z",
      .default = NA_character_
    ),
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
  "glob",
  "mult",
  "endo",
  "podp",
  "surg_bilat",
  "surg_asst",
  "surg_co",
  "surg_team",
  "tot_rvu",
  "op_tot"
)

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
  collapse::sbt(saw, column == "tot_rvu" & value == "0"),
  collapse::sbt(saw, column == "endo" & !cheapr::is_na(value)) |>
    collapse::fgroup_by(column) |>
    collapse::fsummarise(n = sum(n)) |>
    collapse::mtt(value = "1"),
  collapse::sbt(saw, column != "tot_rvu" & column != "endo")
) |>
  # collapse::fcount(column, w = n, add = TRUE) |>
  collapse::mtt(P = n / 18499) |>
  gt::gt(groupname_col = "column", row_group_as_column = TRUE) |>
  gt::tab_header(title = "RVU Overview") |>
  gt::fmt_integer(columns = "n") |>
  gt::fmt_percent(columns = "P", decimals = 0) |>
  gt::cols_label(
    value = "Indicator",
    n = "N"
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
    rows = column == "mod",
    fn = scales::col_numeric(
      palette = "Greens",
      domain = c(0, 16323),
      na.color = "gray"
    )
  ) |>
  gt::data_color(
    columns = n,
    rows = column == "stat",
    fn = scales::col_numeric(
      palette = "Blues",
      domain = c(0, 8975),
      na.color = "gray"
    )
  ) |>
  gt::opt_vertical_padding(scale = 0.65) |>
  gt::sub_missing(missing_text = "-")

list_pins()
