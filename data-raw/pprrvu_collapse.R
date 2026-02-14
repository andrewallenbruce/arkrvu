source(here::here("data-raw", "fns.R"))
library(collapse)

x <- raw_source(2024, "pprrvu")$rvu24a_jan |>
  fastplyr::f_mutate(
    fastplyr::across(
      c(
        pctc_ind,
        mult_proc,
        bilat_surg,
        asst_surg,
        co_surg,
        team_surg
      ),
      nine_
    ),
    fastplyr::across(
      c(
        non_fac_indicator,
        facility_indicator,
        not_used_for_medicare_payment
      ),
      bin_
    ),
    glob_days = glob_(glob_days),
    diag = diag_(diagnostic_imaging_family_indicator),
    has_op = has_op(pre_op, intra_op, post_op),
    has_rvu = has_rvu_(non_facility_total, facility_total)
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
    diag,
    cf = conv_factor
  ) |>
  classify_hcpcs() |>
  fastplyr::f_mutate(
    fastplyr::across(
      c(
        mod,
        stat,
        not_med,
        has_rvu,
        ind_fac,
        ind_non,
        pctc,
        glob,
        mult,
        has_op,
        surg_bilat,
        surg_asst,
        surg_co,
        surg_team,
        diag
      ),
      cheapr::as_factor
    )
  )

x

collapse::rsplit(x, ~has_rvu) |>
  rlang::set_names(c("no_rvu", "has_rvu")) |>
  purrr::map(function(df) {
    df |>
      collapse::fcount(type, section) |>
      collapse::roworder(type, -N)
  })

o <- cheapr::overview(x)

o$numeric |>
  fastplyr::as_tbl() |>
  collapse::slt(column = col, unique = n_unique, mean:hist)

o$categorical |>
  fastplyr::as_tbl() |>
  collapse::mtt(min = providertwo:::clean_title(min)) |>
  collapse::slt(
    column = col,
    missing = n_missing,
    unique = n_unique,
    min,
    max
  ) |>
  print(n = Inf)

saw_names <- c(
  "type",
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
    type,
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
  collapse::mtt(P = n / 18499L) |>
  collapse::sbt(
    !(column == "has_rvu" & value != 0) &
      !(column %in% cols & value == "0")
  ) |>
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
    desc = cheapr::val_match(
      column,
      "stat" ~ recode_status(value),
      "mod" ~ recode_mod(value),
      "pctc" ~ recode_pctc(value),
      "glob" ~ recode_glob(value),
      "mult" ~ recode_mult(value),
      "surg_bilat" ~ recode_bilat(value),
      "surg_asst" ~ recode_asst(value),
      "surg_co" ~ recode_cosurg(value),
      "surg_team" ~ recode_team(value),
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
    rows = column == "section",
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
