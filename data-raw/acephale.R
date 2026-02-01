library(here)
library(tidyverse)
library(gt)
library(arkrvu)
library(northstar)
library(marquee)

expand_date <- function(x) {
  from = collapse::fmin(x)
  to = collapse::fmax(x)

  timeplyr::time_seq(
    lubridate::floor_date(from, unit = "year"),
    lubridate::ceiling_date(to, unit = "year", change_on_boundary = TRUE) -
      lubridate::days(1),
    "day"
  ) |>
    timeplyr::calendar() |>
    collapse::get_vars("^[^iso|epi]", regex = TRUE)
}

PLACE_OF_SRVC <- collapse::ss(northstar::search_pos(), j = 1:2)

## Load CLAIMS
spec <- list(
  id = "character",
  enc = "integer",
  dos = "character",
  dob = "character",
  age = "integer",
  dor = "character",
  lag = "double",
  ref = "character",
  ref_cred = "character",
  ref_tax = "logical",
  ren = "character",
  ren_cred = "character",
  ren_tax = "logical",
  icd = "character",
  ord = "integer",
  hcpcs = "character",
  desc = "character",
  units = "integer",
  mod1 = "character",
  mod2 = "character",
  pos = "character",
  pos_name = "character",
  loc = "character",
  ins_class = "character",
  ins_prim = "character",
  ins_sec = "character",
  charges = "double",
  allowed = "double",
  payments = "double",
  adjustments = "double",
  adj1 = "character",
  adj2 = "character",
  adj3 = "character"
)

claim <- data.table::fread(
  here::here("data-raw/clean_rpt_rend.csv"),
  colClasses = as.list(rlang::set_names(names(spec), unname(spec)))
) |>
  collapse::mtt(
    dos = as.Date(dos),
    dos = as.Date(dos),
    dor = as.Date(dor)
  ) |>
  fastplyr::as_tbl()

pin_update(
  claim,
  "claim",
  "claims dataset",
  "Example Claims Dataset"
)

spec <- list(
  date_start = "character",
  date_end = "character",
  hcpcs = "character",
  description = "character",
  work_rvu = "double",
  pe_rvu = "double",
  mp_rvu = "double",
  rvu_total = "double",
  conv_factor = "double",
  pctc_ind = "character",
  glob_days = "character",
  mult_proc = "character",
  dos = "character",
  pos = "character"
)

pprvu <- data.table::fread(
  here::here("data-raw/results.csv"),
  colClasses = as.list(rlang::set_names(names(spec), unname(spec)))
) |>
  collapse::mtt(
    date_start = as.Date(date_start),
    date_end = as.Date(date_end),
    dos = as.Date(dos)
  ) |>
  fastplyr::as_tbl()

pin_update(
  pprvu,
  "pprvu",
  "PPRVU 2022 for Claims Data",
  "PPRVU 2022 for Claims Data"
)

claim <- claim |>
  fuimus::remove_quiet() |>
  collapse::join(PLACE_OF_SRVC, on = c("pos" = "pos_code")) |>
  collapse::join(expand_date(claim$dos), on = c("dos" = "time")) |>
  collapse::roworder(id, enc) |>
  collapse::mtt(
    ppa = (payments + adjustments),
    allowed = cheapr::case(
      cheapr::is_na(allowed) & charges > (payments + adjustments) ~ payments +
        adjustments,
      cheapr::is_na(allowed) & charges <= (payments + adjustments) ~ payments,
      .default = allowed
    )
  ) |>
  fastplyr::as_tbl()

## Encounters
claim |>
  collapse::slt(
    id,
    enc,
    dos,
    dob,
    age,
    ren,
    ren_cred,
    icd,
    pos,
    pos_name,
    pos_type,
    loc,
    ins_class,
    ins_prim,
    year:wday_l
  ) |>
  collapse::funique()

## Procedures
claim |>
  collapse::slt(
    id,
    enc,
    dos,
    ord,
    hcpcs,
    desc,
    units,
    mod1,
    mod2,
    charges,
    allowed,
    payments,
    adjustments,
    adj1,
    adj2,
    adj3
  ) |>
  collapse::funique()

## Apply transformations
source(here("posts/claims/scripts", "load.R"))

claim |>
  fuimus::combine(adj_codes, c("adj1", "adj2", "adj3"), " | ") |>
  fuimus::combine(mods, c("mod1", "mod2"), " = ") |>
  fuimus::combine(refer, c("ref", "ref_cred"), " <|||") |>
  fuimus::combine(render, c("ren", "ren_cred"), " <|||") |>
  collapse::mtt(
    refer = cheapr::as_factor(stringr::str_replace(
      stringr::str_to_upper(refer),
      "PH D",
      "PHD"
    )),
    render = cheapr::as_factor(stringr::str_to_upper(render)),
    icd = stringr::str_replace_all(icd, ",", " -> "),
    mods = cheapr::as_factor(stringr::str_to_upper(mods)),
    pos = cheapr::as_factor(pos),
    loc = cheapr::as_factor(stringr::str_to_title(loc)),
    adj_codes = stringr::str_replace(adj_codes, " -45", " CO-45")
  ) |>
  collapse::slt(
    id,
    enc,
    dos,
    dob,
    dor,
    age,
    refer,
    render,
    ord,
    icd,
    hcpcs,
    desc,
    units,
    mods,
    pos,
    pos_type,
    loc,
    ins_class,
    ins_prim,
    ins_sec,
    charges,
    allowed,
    payments,
    adjustments,
    adj_codes
  )
