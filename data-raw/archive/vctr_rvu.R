source(here::here("data-raw", "fns.R"))
library(collapse)

# --- LOAD ----
x <- raw_source(2024, "pprrvu")$rvu24a_jan |>
  collapse::slt(
    hcpcs,
    mod,
    wk = work_rvu,
    mp = mp_rvu,
    pe_non = non_fac_pe_rvu,
    pe_fac = facility_pe_rvu
  ) |>
  collapse::roworder(hcpcs) |>
  # collapse::mtt(id = seq_along(x$hcpcs)) |>
  # collapse::colorder(id) |>
  # --- Filter out rows where all RVU components are zero ----
  collapse::sbt(wk + mp + pe_non + pe_fac != 0L)


# --- MODIFIERS ----
# --- Filter out rows where mod is NA ----
x_mod <- x |>
  collapse::sbt(!is.na(mod))

x_mod_eq <- x_mod |>
  collapse::sbt(pe_fac == pe_non, -pe_fac) |>
  collapse::frename(pe = pe_non) |>
  collapse::mtt(pos = "Both")

x_mod_uneq <- x_mod |>
  collapse::sbt(pe_fac != pe_non) |>
  collapse::pivot(
    ids = c("hcpcs", "mod", "wk", "mp"),
    values = c("pe_fac", "pe_non"),
    names = list(value = "pe", variable = "pos")
  ) |>
  collapse::mtt(
    pos = as.character(pos),
    pos = cheapr::val_match(
      pos,
      "pe_non" ~ "Non-Facility",
      "pe_fac" ~ "Facility",
      .default = NA_character_
    )
  )

x_mod <- vctrs::vec_rbind(x_mod_eq, x_mod_uneq)

# Rows where mod is NA
x_pos <- x |>
  collapse::sbt(hcpcs %!in% x_mod$hcpcs, -mod)

# Rows where pF == pN
x_pos_eq <- x_pos |>
  collapse::sbt(pe_fac == pe_non, -pe_fac) |>
  collapse::frename(pe = pe_non) |>
  collapse::mtt(pos = "Both")

x_pos_uneq <- x_pos |>
  collapse::sbt(hcpcs %!in% x_pos_eq$hcpcs) |>
  collapse::pivot(
    ids = c("hcpcs", "wk", "mp"),
    values = c("pe_non", "pe_fac"),
    names = list(value = "pe", variable = "pos")
  ) |>
  collapse::mtt(
    pos = as.character(pos),
    pos = cheapr::val_match(
      pos,
      "pe_non" ~ "Non-Facility",
      "pe_fac" ~ "Facility",
      .default = NA_character_
    )
  )

x_rvu <- vctrs::vec_rbind(
  x_pos_eq,
  x_pos_uneq,
  x_mod
)

x_rvu |>
  collapse::fcount(hcpcs, sort = TRUE) |>
  collapse::roworder(-N) |>
  collapse::sbt(N >= 3L)

x_rvu |>
  collapse::fcount(mod, sort = TRUE) |>
  collapse::roworder(-N)

x_rvu |>
  collapse::mtt(
    id = seq_len(nrow(x_rvu)),
    wg = 1,
    pg = 0.883,
    mg = 1.125,
    w = wk * wg,
    p = pr * pg,
    m = mp * mg,
    sum = w + p + m,
    tot = sum * 32.744
  )


pin_update(
  x_rvu,
  name = "vctr_rvu",
  title = "Toy dataset for vctr class"
)

get_pin("vctr_rvu")
