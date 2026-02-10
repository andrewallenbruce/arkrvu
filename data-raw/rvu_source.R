source(here::here("data-raw", "data_pins.R"))

download_rvu_zips <- function(years, directory) {
  urls <- rvu_zip_links(years)$url
  file <- rvu_zip_links(years)$file

  dir <- tempdir()
  paths <- stringr::str_glue("{dir}{file}.zip")

  curl::multi_download(
    urls = urls,
    destfile = paths,
    resume = TRUE,
    multi_timeout = Inf
  )

  csvs <- paths |>
    purrr::map(zip::zip_list) |>
    purrr::set_names(basename(paths)) |>
    purrr::list_rbind(names_to = "file") |>
    dplyr::tibble() |>
    dplyr::mutate(size = fs::as_fs_bytes(uncompressed_size)) |>
    dplyr::select(
      file,
      sub_file = filename,
      timestamp,
      size
    ) |>
    dplyr::filter(grepl(".csv", sub_file)) |>
    dplyr::arrange(sub_file)

  purrr::pwalk(list(zipfile = paths, exdir = dir), zip::unzip)

  csvs <- fs::dir_ls(dir, glob = "*.csv")
  unlink(dir, recursive = TRUE)
}

zip_list <- unpack_rvu_zips(
  zip_paths,
  directory = "D:/MPFS Files Archive/unzipped/"
)

raw_files <- process_raw_xlsx()


#--- PPRRVU ####
raw_pprrvu <- create_list(
  raw = raw_files,
  list = "pprrvu",
  remove = "_pprrvu[0-9]{2}"
)
pprrvu <- purrr::map(raw_pprrvu, process_pprrvu)

#--- OPPSCAP ####
raw_oppscap <- create_list(
  raw = raw_files,
  list = "oppscap",
  remove = "_oppscap"
)
oppscap <- purrr::map(raw_oppscap, process_oppscap)

#--- GPCI ####
raw_gpci <- create_list(
  raw = raw_files,
  list = "gpci",
  remove = "_gpci[0-9]{0,4}"
)
# gpci <- purrr::map(raw_gpci, process_gpci)
gpci <- purrr::map(raw_gpci, process_gpci2)

#--- LOCCO ####
raw_locco <- create_list(
  raw = raw_files,
  list = "locco",
  remove = "_[0-9]{2}locco"
)
# locco <- purrr::map(raw_locco, process_locco)
locco <- purrr::map(raw_locco, process_locco2)

#--- ANES ####
raw_anes <- create_list(
  raw = raw_files,
  list = "anes",
  remove = "_anes[0-9]{4}"
)
anes <- purrr::map(raw_anes, process_anes)

#--- SOURCE ####
rvu_source <- list(
  table = zip_table |>
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
