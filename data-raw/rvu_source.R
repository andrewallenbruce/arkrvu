source(here::here("data-raw", "pins_functions.R"))
source(here::here("data-raw", "rvu_functions.R"))

year       <- 2020
link_table <- get_pin("rvu_link_table")
rvu_pages  <- download_rvu_pages(link_table, year = year)
zip_table  <- process_rvu_pages(rvu_pages, link_table, year = year)
zip_paths  <- download_rvu_zips(zip_table, directory = "D:/MPFS Files Archive/")
zip_list   <- unpack_rvu_zips(zip_paths, directory = "D:/MPFS Files Archive/unzipped/")

raw_files  <- process_raw_xlsx()



#--- PPRRVU ####
raw_pprrvu <- create_list(raw = raw_files, list = "pprrvu", remove = "_pprrvu[0-9]{2}")
pprrvu <- purrr::map(raw_pprrvu, process_pprrvu)

#--- OPPSCAP ####
raw_oppscap <- create_list(raw = raw_files, list = "oppscap", remove = "_oppscap")
oppscap <- purrr::map(raw_oppscap, process_oppscap)

#--- GPCI ####
raw_gpci <- create_list(raw = raw_files, list = "gpci", remove = "_gpci[0-9]{0,4}")
# gpci <- purrr::map(raw_gpci, process_gpci)
gpci <- purrr::map(raw_gpci, process_gpci2)

#--- LOCCO ####
raw_locco <- create_list(raw = raw_files, list = "locco", remove = "_[0-9]{2}locco")
# locco <- purrr::map(raw_locco, process_locco)
locco <- purrr::map(raw_locco, process_locco2)

#--- ANES ####
raw_anes <- create_list(raw = raw_files, list = "anes", remove = "_anes[0-9]{4}")
anes <- purrr::map(raw_anes, process_anes)

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
