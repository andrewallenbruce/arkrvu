library(collapse)

x <- get_pin("rvu_source_2024")$pprrvu$rvu24a_jan

# x |>
#   collapse::sbt(hcpcs == "0509T") |>
#   dplyr::glimpse()

x <- x |>
  collapse::slt(
    hcpcs,
    mod,
    w = work_rvu,
    m = mp_rvu,
    pN = non_fac_pe_rvu,
    pF = facility_pe_rvu
  ) |>
  collapse::roworder(hcpcs) |>
  collapse::mtt(id = seq_along(x$hcpcs)) |>
  collapse::colorder(id)

# Filter out rows where all RVU components are zero
x <- x |>
  collapse::sbt(w + pN + pF + m != 0L)

# Filter out rows where mod is NA
x_mod <- x |>
  collapse::sbt(!is.na(mod))

x_mod_equal <- x_mod |>
  collapse::sbt(pF == pN, -pF) |>
  collapse::frename(p = pN) |>
  collapse::mtt(
    modified = glue::glue("MOD [{mod}]"),
    mod = NULL
  )

x_mod_uneq <- x_mod |>
  collapse::sbt(pF != pN) |>
  collapse::pivot(
    ids = c("id", "mod", "hcpcs", "w", "m"),
    values = c("pF", "pN"),
    names = list(value = "p", variable = "pos")
  ) |>
  collapse::mtt(
    pos = as.character(pos),
    pos = cheapr::val_match(
      pos,
      "pN" ~ "NON",
      "pF" ~ "FAC",
      .default = NA_character_
    )
  ) |>
  collapse::mtt(
    modified = glue::glue("MOD [{mod}] POS [{pos}]"),
    mod = NULL,
    pos = NULL
  ) |>
  collapse::slt(id, hcpcs, w, m, p, modified)

x_mod <- vctrs::vec_rbind(x_mod_equal, x_mod_uneq)

# Rows where mod is NA
x_pos <- x |>
  collapse::sbt(id %!in% x_mod$id, -mod)

# Rows where pF == pN
x_pos_equal <- x_pos |>
  collapse::sbt(pF == pN, -pF) |>
  collapse::frename(p = pN) |>
  collapse::mtt(modified = NA_character_ |> glue::as_glue())

x_pos_uneq <- x_pos |>
  collapse::sbt(id %!in% x_pos_equal$id) |>
  collapse::pivot(
    ids = c("id", "hcpcs", "w", "m"),
    values = c("pF", "pN"),
    names = list(value = "p", variable = "pos")
  ) |>
  collapse::mtt(
    pos = as.character(pos),
    pos = cheapr::val_match(
      pos,
      "pN" ~ "NON",
      "pF" ~ "FAC",
      .default = NA_character_
    )
  ) |>
  collapse::mtt(
    modified = glue::glue("POS [{pos}]"),
    pos = NULL
  ) |>
  collapse::slt(id, hcpcs, w, m, p, modified)

x_rvu <- vctrs::vec_rbind(
  x_pos_equal,
  x_pos_uneq,
  x_mod
) |>
  collapse::roworder(id) |>
  collapse::slt(-id)

pin_update(
  x_rvu,
  name = "vctr_rvu",
  title = "Toy dataset for vctr class"
)
