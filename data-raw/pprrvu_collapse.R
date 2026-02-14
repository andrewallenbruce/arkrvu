source(here::here("data-raw", "fns.R"))
library(collapse)

x <- raw_source(2024, "pprrvu")$rvu24a_jan

cf <- collapse::funique(x$conv_factor)

x <- x |>
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
    has_rvu = has_rvu_(non_facility_total, facility_total),
    has_mod = bin_(mod)
  ) |>
  collapse::slt(
    hcpcs,
    desc = description,
    mod,
    has_mod,
    stat = status_code,
    rvu_wk = work_rvu,
    rvu_pe_non = non_fac_pe_rvu,
    rvu_pe_fac = facility_pe_rvu,
    rvu_mp = mp_rvu,
    has_rvu,
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
    diag
  ) |>
  # classify_hcpcs() |>
  fastplyr::f_mutate(
    fastplyr::across(
      c(
        mod,
        stat,
        has_rvu,
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

col_ind <- colnames(x)[c(1, 6:8, 13:26)]
col_rvu <- colnames(x)[c(1, 6:7, 9:13)]

rvu <- collapse::slt(x, col_rvu) |>
  collapse::rsplit(~has_rvu) |>
  rlang::set_names(c("no_rvu", "has_rvu"))

no_rvu <- rvu$no_rvu$hcpcs

rvu$has_rvu <- collapse::rowbind(
  rvu$has_rvu |>
    collapse::sbt(rvu_pe_fac == rvu_pe_non, -rvu_pe_fac) |>
    collapse::frename(rvu_pe = rvu_pe_non) |>
    collapse::mtt(pos = "E"),
  rvu$has_rvu |>
    collapse::sbt(rvu_pe_fac != rvu_pe_non) |>
    collapse::pivot(
      values = c("rvu_pe_fac", "rvu_pe_non"),
      names = list(value = "rvu_pe", variable = "pos")
    ) |>
    collapse::mtt(
      pos = as.character(pos),
      pos = cheapr::val_match(
        pos,
        "rvu_pe_non" ~ "N",
        "rvu_pe_fac" ~ "F",
        .default = NA_character_
      )
    )
) |>
  collapse::mtt(pos = cheapr::as_factor(pos)) |>
  collapse::roworder(hcpcs, pos) |>
  collapse::colorder(hcpcs, rvu_wk, rvu_mp, rvu_pe, pos)

rvu$has_rvu <- rvu$has_rvu |>
  collapse::rsplit(~has_mod) |>
  rlang::set_names(c("no_mod", "has_mod"))

rvu$has_rvu$no_mod <- collapse::slt(rvu$has_rvu$no_mod, -mod)

rvu <- rvu$has_rvu$has_mod |>
  collapse::mtt(
    hcpcs = as.character(stringr::str_glue("{hcpcs}-{mod}")),
    mod = NULL
  ) |>
  collapse::rowbind(rvu$has_rvu$no_mod) |>
  collapse::roworder(hcpcs)

ind <- collapse::slt(x, col_ind) |>
  collapse::mtt(
    hcpcs = cheapr::if_else_(
      has_mod == 1L,
      as.character(stringr::str_glue("{hcpcs}-{mod}")),
      hcpcs
    ),
    mod = NULL,
    has_mod = NULL
  )

x <- list(
  file = "RVU24A",
  cf = cf,
  rvu = rvu,
  ind = ind
)

# hcpcs_idx <- fastplyr::new_tbl(
#   idx = indexthis::to_index(hcpcs_idx$hcpcs),
#   hcpcs = indexthis::to_index(hcpcs_idx$hcpcs, items = TRUE)$items
# ) |>
#   collapse::join(hcpcs_idx)

# x <- collapse::slt(x, -c(type, level, section, desc)) |>
#   collapse::join(collapse::ss(hcpcs_idx, j = 1:2)) |>
#   collapse::colorder(idx)
