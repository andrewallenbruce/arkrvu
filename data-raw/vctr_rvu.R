source(here::here("data-raw", "pins_functions.R"))
source(here::here("data-raw", "rvu_functions.R"))
library(collapse)

# --- LOAD ----
x <- get_pin("rvu_source_2024")$pprrvu$rvu24a_jan

# --- INIT ----
x <- x |>
  collapse::slt(
    hcpcs,
    mod,
    wk = work_rvu,
    mp = mp_rvu,
    pr_non = non_fac_pe_rvu,
    pr_fac = facility_pe_rvu
  ) |>
  collapse::roworder(hcpcs) |>
  collapse::mtt(id = seq_along(x$hcpcs)) |>
  collapse::colorder(id) |>
  # --- Filter out rows where all RVU components are zero ----
  collapse::sbt(wk + mp + pr_non + pr_fac != 0L)


# --- MODIFIERS ----
# --- Filter out rows where mod is NA ----
x_mod <- x |>
  collapse::sbt(!is.na(mod))

x_mod_equal <- x_mod |>
  collapse::sbt(pr_fac == pr_non, -pr_fac) |>
  collapse::frename(pr = pr_non) |>
  collapse::mtt(modifier = glue::glue("[mod] {mod}"), mod = NULL)

x_mod_uneq <- x_mod |>
  collapse::sbt(pr_fac != pr_non) |>
  collapse::pivot(
    ids = c("id", "hcpcs", "mod", "wk", "mp"),
    values = c("pr_fac", "pr_non"),
    names = list(value = "pr", variable = "pos")
  ) |>
  collapse::mtt(
    pos = as.character(pos),
    pos = cheapr::val_match(
      pos,
      "pr_non" ~ "Non-Facility",
      "pr_fac" ~ "Facility",
      .default = NA_character_
    )
  ) |>
  collapse::mtt(
    modifier = glue::glue("[mod] {mod}, [pos] {pos}"),
    mod = NULL,
    pos = NULL
  ) |>
  collapse::slt(id, hcpcs, wk, mp, pr, modifier)

x_mod <- vctrs::vec_rbind(x_mod_equal, x_mod_uneq)

# Rows where mod is NA
x_pos <- x |>
  collapse::sbt(id %!in% x_mod$id, -mod)

# Rows where pF == pN
x_pos_equal <- x_pos |>
  collapse::sbt(pr_fac == pr_non, -pr_fac) |>
  collapse::frename(pr = pr_non) |>
  collapse::mtt(modifier = NA_character_ |> glue::as_glue())

x_pos_uneq <- x_pos |>
  collapse::sbt(id %!in% x_pos_equal$id) |>
  collapse::pivot(
    ids = c("id", "hcpcs", "wk", "mp"),
    values = c("pr_non", "pr_fac"),
    names = list(value = "pr", variable = "pos")
  ) |>
  collapse::mtt(
    pos = as.character(pos),
    pos = cheapr::val_match(
      pos,
      "pr_non" ~ "Non-Facility",
      "pr_fac" ~ "Facility",
      .default = NA_character_
    )
  ) |>
  collapse::mtt(modifier = glue::glue("[pos] {pos}"), pos = NULL) |>
  collapse::slt(id, hcpcs, wk, mp, pr, modifier)

x_rvu <- vctrs::vec_rbind(
  x_pos_equal,
  x_pos_uneq,
  x_mod
) |>
  collapse::roworder(id) |>
  collapse::slt(-id)

x_rvu |>
  collapse::fcount(hcpcs, sort = TRUE) |>
  collapse::roworder(-N) |>
  collapse::sbt(N >= 3L)

x_rvu |>
  collapse::fcount(modifier, sort = TRUE) |>
  collapse::roworder(-N) |>
  collapse::sbt(N >= 3L)

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
