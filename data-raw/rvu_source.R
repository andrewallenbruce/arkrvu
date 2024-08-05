source(here::here("data-raw", "pins_functions.R"))
source(here::here("data-raw", "rvu_functions.R"))

link_table <- get_link_table()
year       <- 2022

rvu_pages  <- download_rvu_pages(link_table, year = year)
zip_table  <- process_rvu_pages(rvu_pages, link_table, year = year)
zip_paths  <- download_rvu_zips(zip_table, directory = "data-raw")
zip_list   <- unpack_rvu_zips(zip_paths, directory = "data-raw")


rvu_folders      <- fs::dir_ls(here::here("data-raw"), regexp = "RVU")
rvu_folder_names <- basename(rvu_folders)
rvu_xlsx_files   <- fs::dir_ls(rvu_folders, glob = "*.xlsx")
rvu_setnames <- stringr::str_remove_all(rvu_xlsx_files, ".xlsx") |>
  strex::str_after_nth("/", -2) |>
  stringr::str_replace("/", "_") |>
  tolower()

raw <- rvu_xlsx_files |>
  purrr::map(readxl::read_excel, col_types = "text") |>
  purrr::map(fuimus::df_2_chr) |>
  purrr::set_names(rvu_setnames)

#--- PPRRVU ####
raw_pprrvu <- create_list(raw = raw, list = "pprrvu")

pprrvu <- purrr::map(raw_pprrvu, process_pprrvu) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "pprrvu") |>
      stringr::str_remove("_pprrvu[0-9]{2}"))

#--- OPPSCAP ####
#
# OPPSCAP contains the payment amounts after the application of the
# OPPS-based payment caps, except for carrier priced codes. For carrier
# price codes, the field only contains the OPPS-based payment caps. Carrier
# prices cannot exceed the OPPS-based payment caps.

raw_oppscap <- create_list(raw = raw, list = "oppscap")

oppscap <- purrr::map(raw_oppscap, process_oppscap) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "oppscap") |>
      stringr::str_remove("_oppscap"))

#--- GPCI ####
#
# ADDENDUM E. FINAL CY 2024 GEOGRAPHIC PRACTICE COST INDICES (GPCIs) BY STATE AND MEDICARE LOCALITY
# https://www.ama-assn.org/system/files/geographic-practice-cost-indices-gpcis.pdf

raw_gpci <- create_list(raw = raw, list = "gpci")

gpci <- purrr::map(raw_gpci, process_gpci) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "gpci") |>
      stringr::str_remove("_gpci[0-9]{0,4}")
    )

#--- LOCCO ####
#
# counties included in 2024 localities alphabetically
# by state and locality name within state
#
# * = Payment locality is serviced by two carriers.

raw_locco <- create_list(raw = raw, list = "locco")

locco <- purrr::map(raw_locco, process_locco) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "locco") |>
      stringr::str_remove("_[0-9]{2}locco")
  )

#--- ANES ####
raw_anes <- create_list(raw = raw, list = "anes")

anes <- purrr::map(raw_anes, process_anes) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "anes") |>
      stringr::str_remove("_anes[0-9]{4}")
  )

#--- SOURCE ####
rvu_source <- list(
  table  = zip_table |>
    dplyr::left_join(zip_list, by = dplyr::join_by(file_html)) |>
    tidyr::nest(sub_files = c(sub_file, sub_file_timestamp)),
  pprrvu = pprrvu,
  oppscap = oppscap,
  gpci = gpci,
  locco = locco,
  anes = anes
)

#--- PINS ####
pin_update(
  rvu_source,
  name = stringr::str_glue("rvu_source_{year}") |> as.character(),
  title = stringr::str_glue("RVU Source Files {year}") |> as.character()
)

#--- CLEANUP ####
fs::dir_delete(fs::dir_ls("data-raw", regexp = "RVU\\d{2}[A-Z]{0,2}"))
