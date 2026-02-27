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
    glob_days = glob_(glob_days),
    diag = diag_(diagnostic_imaging_family_indicator),
    has_op = has_op(pre_op, intra_op, post_op),
    has_rvu = has_rvu_(non_facility_total, facility_total),
    has_mod = bin_(mod),
    hcpcs = cheapr::if_else_(
      has_mod == 1L,
      as.character(stringr::str_glue("{hcpcs}-{mod}")),
      hcpcs
    ),
    mod = NULL,
    has_mod = NULL
  ) |>
  collapse::slt(
    hcpcs,
    desc = description,
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
  )

x

hcpcs <- collapse::gvr(x, "^hcpcs$|^stat$|^desc$") |>
  collapse::mtt(hcpcs = substr(hcpcs, 1, 5)) |>
  collapse::funique() |>
  classify_hcpcs()

rvu <- collapse::gvr(x, "^hcpcs$|^rvu_|_rvu$") |>
  collapse::rsplit(~has_rvu) |>
  rlang::set_names(c("no_rvu", "has_rvu"))

no_rvu <- rvu$no_rvu$hcpcs

rvu <- rvu$has_rvu

rvu <- collapse::rowbind(
  collapse::sbt(rvu, rvu_pe_fac == rvu_pe_non, -rvu_pe_fac) |>
    collapse::rnm(rvu_pe = rvu_pe_non) |>
    collapse::mtt(pos = "B"),
  collapse::sbt(rvu, rvu_pe_fac != rvu_pe_non) |>
    collapse::pivot(
      values = c("rvu_pe_fac", "rvu_pe_non"),
      names = list(value = "rvu_pe", variable = "pos"),
      nthreads = 4L
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
  # collapse::mtt(pos = cheapr::as_factor(pos)) |>
  collapse::roworder(hcpcs, pos) |>
  collapse::colorder(hcpcs, rvu_wk, rvu_mp, rvu_pe, pos)

op <- collapse::gvr(x, "^hcpcs$|^has_op$|^op_") |>
  collapse::roworder(hcpcs) |>
  collapse::sbt(has_op == 1L, -has_op) |>
  collapse::mtt(
    op_pre = as.integer(op_pre * 100),
    op_intra = as.integer(op_intra * 100),
    op_post = as.integer(op_post * 100)
  )

pctc <- collapse::gvr(x, "^hcpcs$|^pctc$") |>
  collapse::roworder(hcpcs) |>
  collapse::mtt(
    mod = substr(hcpcs, 7, 8),
    mod = cheapr::if_else_(nzchar(mod), mod, NA_character_),
    hcpcs = substr(hcpcs, 1, 5),
    pctc = strtoi(pctc),
    rule = recode_pctc(pctc, "rule"),
    lab = recode_pctc(pctc)
  ) |>
  collapse::funique() |>
  collapse::sbt(!(pctc == 0L | is.na(pctc))) |>
  collapse::sbt(!(pctc == 1L & is.na(mod)))

# |>
#   collapse::fcount(mod, pctc, rule, lab) |>
#   collapse::roworder(-N)

surg <- collapse::gvr(x, "^hcpcs$|^surg_") |>
  collapse::roworder(hcpcs) |>
  collapse::sbt(
    !(cheapr::is_na(surg_bilat) &
      cheapr::is_na(surg_asst) &
      cheapr::is_na(surg_co) &
      cheapr::is_na(surg_team))
  ) |>
  purrr::set_names(c("hcpcs", "bilat", "asst", "cosurg", "team")) |>
  collapse::mtt(hcpcs = substr(hcpcs, 1, 5)) |>
  collapse::funique() |>
  collapse::pivot(
    ids = c("hcpcs"),
    values = c("bilat", "asst", "cosurg", "team"),
    names = list(value = "ind", variable = "surg")
  ) |>
  collapse::sbt(!is.na(ind)) |>
  collapse::mtt(
    surg = as.character(surg),
    label = cheapr::case(
      surg == "bilat" ~ recode_bilat(ind),
      surg == "cosurg" ~ recode_cosurg(ind),
      surg == "team" ~ recode_team(ind),
      surg == "asst" ~ recode_asst(ind),
      .default = NA_character_
    )
  ) |>
  collapse::rsplit(~surg)

# surg |>
#   purrr::map(
#     ~ collapse::funique(.x) |>
#       collapse::fcount(ind, label, sort = TRUE) |>
#       collapse::roworder(-N)
#   )

bilat <- surg$bilat
surg$asst <- collapse::sbt(surg$asst, ind != 1L) |> collapse::funique()
surg$cosurg <- collapse::sbt(surg$cosurg, ind != 0L) |> collapse::funique()
surg$team <- collapse::sbt(surg$team, ind != 0L) |> collapse::funique()
surg$bilat <- NULL
surg <- collapse::rowbind(surg, idcol = TRUE, id.factor = FALSE) |>
  collapse::funique()

surg |>
  collapse::fcount(hcpcs) |>
  collapse::roworder(-N) |>
  collapse::sbt(N > 2) |>
  classify_hcpcs() |>
  print(n = 50)

endo <- collapse::gvr(x, "^hcpcs$|^endo$|^mult$") |>
  collapse::sbt(!is.na(endo)) |>
  collapse::funique() |>
  collapse::roworder(hcpcs)

endo |>
  collapse::fcount(mult) |>
  collapse::roworder(-N)

glob <- collapse::gvr(x, "^hcpcs$|^glob$") |>
  collapse::mtt(hcpcs = substr(hcpcs, 1, 5)) |>
  collapse::sbt(!is.na(glob)) |>
  collapse::funique() |>
  collapse::roworder(hcpcs)

glob |>
  collapse::fcount(glob) |>
  collapse::roworder(-N)

diag <- collapse::gvr(x, "^hcpcs$|^diag$") |>
  collapse::mtt(hcpcs = substr(hcpcs, 1, 5)) |>
  collapse::sbt(!is.na(diag)) |>
  collapse::funique() |>
  collapse::roworder(hcpcs)

glob |>
  collapse::fcount(glob) |>
  collapse::roworder(-N)

mult <- collapse::gvr(x, "^hcpcs$|^mult$") |>
  collapse::mtt(hcpcs = substr(hcpcs, 1, 5)) |>
  collapse::funique() |>
  collapse::roworder(hcpcs) |>
  collapse::sbt(!cheapr::is_na(mult))

file <- list(
  file = "RVU24A",
  cf = cf,
  hcpcs = hcpcs,
  rvu = rvu,
  ind = ind,
  op = op,
  pctc = pctc,
  surg = surg,
  endo = endo
)


file$ind |>
  collapse::mtt(
    ind = as.character(ind),
    re = cheapr::val_match(
      as.character(desc),
      "glob" ~ recode_glob(ind),
      "mult" ~ recode_mult(ind),
      "diag" ~ recode_diag(ind),
      .default = NA_character_
    )
  ) |>
  collapse::fcount(desc, re, sort = TRUE)

file$hcpcs |>
  collapse::fcount(stat, sort = TRUE)

# hcpcs_idx <- fastplyr::new_tbl(
#   idx = indexthis::to_index(hcpcs_idx$hcpcs),
#   hcpcs = indexthis::to_index(hcpcs_idx$hcpcs, items = TRUE)$items
# ) |>
#   collapse::join(hcpcs_idx)

# x <- collapse::slt(x, -c(type, level, section, desc)) |>
#   collapse::join(collapse::ss(hcpcs_idx, j = 1:2)) |>
#   collapse::colorder(idx)
