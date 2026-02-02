paths <- fs::dir_ls("C:/Users/Andrew/Downloads/rvu26ar_1")
paths <- paths[cheapr::which_(fs::path_ext(paths) == "pdf", invert = TRUE)]

idx_csv <- cheapr::which_(fs::path_ext(paths) == "csv")
idx_xls <- cheapr::which_(fs::path_ext(paths) %in% c("xlsx", "xls"))
idx_txt <- cheapr::which_(fs::path_ext(paths) == "txt")

# === ANES2026.csv
paths[idx_csv][2] |>
  data.table::fread() |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  janitor::clean_names()

# ===|===|===|=== GPCI2026.csv
# ADDENDUM E. FINAL CY 2026
# GEOGRAPHIC PRACTICE COST INDICES
# BY STATE AND MEDICARE LOCALITY
gpci_columns <- c(
  "mac",
  "state",
  "locality_number",
  "locality_name",
  "x2026_pw_gpci_without_1_0_floor",
  "x2026_pw_gpci_without_1_0_floor",
  "x2026_pw_gpci_without_1_0_floor",
  "x2026_pw_gpci_without_1_0_floor"
)
paths[idx_csv][3] |>
  data.table::fread(skip = 2L) |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  janitor::clean_names() |>
  rlang::set_names(gpci_columns)

# === 26LOCCO.csv
# COUNTIES INCLUDED IN 2026 LOCALITIES.
locco_columns <- c(
  "mac",
  "locality_number",
  "state",
  "fee_sched_area",
  "county"
)

locco <- paths[idx_csv][1] |>
  data.table::fread(skip = 2) |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  janitor::clean_names() |>
  rlang::set_names(locco_columns)

# remove empty rows
locco <- locco[!cheapr::row_all_na(locco), ]
# remove last row with note
locco <- locco[seq_len(nrow(locco) - 1L), ]
# fill down state names
locco$state <- vctrs::vec_fill_missing(locco$state, direction = "down")

# === OPPSCAP_Jan.csv
paths[idx_csv][4] |>
  data.table::fread() |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  janitor::clean_names()

# === PPRRVU2026_Jan_nonQPP.csv
# 2026 National Physician Fee Schedule
# Relative Value File January Release
# RELEASED 12/29/2025

# Column Names
colnames_nonQPP <- paths[idx_csv][5] |>
  data.table::fread(skip = 6L, nrows = 4L) |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  collapse::pivot(na.rm = TRUE) |>
  collapse::fgroup_by(variable) |>
  collapse::fsummarise(value = paste0(value, collapse = " ")) |>
  _$value |>
  janitor::make_clean_names()

paths[idx_csv][5] |>
  data.table::fread(skip = 9L) |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  rlang::set_names(colnames_nonQPP) |>
  dplyr::glimpse()

# === PPRRVU2026_Jan_QPP.csv
# 2026 National Physician Fee Schedule
# Relative Value File January Release
# RELEASED 12/29/2025

# paths[idx_csv][6] |> brio::read_lines(n = 10)

# Column Names
colnames_QPP <- paths[idx_csv][6] |>
  data.table::fread(skip = 6L, nrows = 4L) |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  collapse::pivot(na.rm = TRUE) |>
  collapse::fgroup_by(variable) |>
  collapse::fsummarise(value = paste0(value, collapse = " ")) |>
  _$value |>
  janitor::make_clean_names()

paths[idx_csv][6] |>
  data.table::fread(skip = 9L) |>
  fastplyr::as_tbl() |>
  providertwo:::map_na_if() |>
  rlang::set_names(colnames_QPP)

pin_update(
  pprvu,
  "pprvu",
  "PPRVU 2022 for Claims Data",
  "PPRVU 2022 for Claims Data"
)
