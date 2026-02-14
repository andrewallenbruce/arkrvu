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
