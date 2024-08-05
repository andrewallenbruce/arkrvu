source(here::here("data-raw", "pins_functions.R"))
source(here::here("data-raw", "rvu_functions.R"))

link_table <- get_link_table()
year       <- 2023

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

create_list <- function(raw, list) {

  raw_to_string <- stringr::str_c(
    stringr::str_glue(
      "raw${stringr::str_subset(names(raw), list)}"),
    collapse = ", "
  )

  raw_to_list <- stringr::str_c("list(", raw_to_string, ")")

  rlang::eval_tidy(rlang::parse_expr(raw_to_list))
}

#--- PPRRVU ####
raw_pprrvu <- create_list(raw = raw, list = "pprrvu")

process_pprrvu <- function(x) {

  dplyr::slice(
    x,
    5:dplyr::n()
    ) |>
    unheadr::mash_colnames(
      n_name_rows = 5,
      keep_names = FALSE
      ) |>
    janitor::clean_names() |>
    dplyr::filter(
      !is.na(calculation_flag)
      ) |>
    dplyr::mutate(
      dplyr::across(
        c(
          dplyr::contains("rvu"),
          dplyr::contains("total"),
          dplyr::contains("_op"),
          conv_factor
        ),
        readr::parse_number)
    )

}

pprrvu <- purrr::map(raw_pprrvu, process_pprrvu) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "pprrvu") |>
      stringr::str_remove("_pprrvu[0-9]{2}"))

pprrvu

#--- OPPSCAP ####
#
# OPPSCAP contains the payment amounts after the application of the
# OPPS-based payment caps, except for carrier priced codes. For carrier
# price codes, the field only contains the OPPS-based payment caps. Carrier
# prices cannot exceed the OPPS-based payment caps.

raw_oppscap <- create_list(raw = raw, list = "oppscap")


process_oppscap <- function(x) {

  dplyr::filter(x, HCPCS != "\u001a") |>
    janitor::clean_names() |>
    dplyr::mutate(
      dplyr::across(
        dplyr::contains("price"),
        readr::parse_number)
    ) |>
    dplyr::rename(
      non_facility_price = non_facilty_price
    )
}

oppscap <- purrr::map(raw_oppscap, process_oppscap) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "oppscap") |>
      stringr::str_remove("_oppscap"))

oppscap

# GPCI ####
#
# ADDENDUM E. FINAL CY 2024 GEOGRAPHIC PRACTICE COST INDICES (GPCIs) BY STATE AND MEDICARE LOCALITY
# https://www.ama-assn.org/system/files/geographic-practice-cost-indices-gpcis.pdf

raw_gpci <- create_list(raw = raw, list = "gpci")

process_gpci <- function(x) {

  x <- unheadr::mash_colnames(
    x,
    n_name_rows = 2,
    keep_names = FALSE
    ) |>
    janitor::clean_names() |>
    dplyr::filter(!is.na(state))

  names(x) <- c(
    "mac",
    "state",
    "locality_number",
    "locality_name",
    "gpci_work",
    "gpci_pe",
    "gpci_mp"
    )

  x |>
    dplyr::mutate(
      dplyr::across(
        c(gpci_work, gpci_pe, gpci_mp),
        readr::parse_number
        ),
      locality_name = stringr::str_remove_all(
        locality_name, stringr::fixed("*")
        ),
      gpci_gaf = (gpci_work + gpci_pe + gpci_mp) / 3
    )
}

gpci <- purrr::map(raw_gpci, process_gpci) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "gpci") |>
      stringr::str_remove("_gpci[0-9]{0,4}")
    )

gpci

# LOCCO
#
# counties included in 2024 localities alphabetically
# by state and locality name within state
#
# * = Payment locality is serviced by two carriers.

raw_locco <- create_list(raw = raw, list = "locco")

process_locco <- function(x) {

  df_state <- dplyr::tibble(
    state_abb = state.abb,
    state = toupper(state.name)
  )

  unheadr::mash_colnames(
    x,
    n_name_rows = 2,
    keep_names = FALSE
    ) |>
    janitor::clean_names() |>
    dplyr::filter(!is.na(medicare_adminstrative_contractor)) |>
    tidyr::fill(state) |>
    dplyr::reframe(
      mac = medicare_adminstrative_contractor,
      locality_number,
      state,
      fee_schedule_area = stringr::str_remove_all(fee_schedule_area, stringr::fixed("*")),
      counties
    ) |>
    dplyr::left_join(df_state, by = dplyr::join_by(state)) |>
    dplyr::mutate(
      state = dplyr::case_match(
        state_abb,
        "DC" ~ "DISTRICT OF COLUMBIA",
        "PR" ~ "PUERTO RICO",
        "VI" ~ "VIRGIN ISLANDS",
        .default = state
      )
    )
}

locco <- purrr::map(raw_locco, process_locco) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "locco") |>
      stringr::str_remove("_[0-9]{2}locco")
  )

#----------- ANES ####
raw_anes <- create_list(raw = raw, list = "anes")

process_anes <- function(x) {

  names(x) <- c(
    "contractor",
    "locality",
    "locality_name",
    "anesthesia_conv_factor"
    )

  x |>
    dplyr::reframe(
      contractor,
      locality = dplyr::if_else(
        stringr::str_length(locality) != 2,
        stringr::str_pad(locality, 2, pad = "0"),
        locality),
      locality_name = stringr::str_remove_all(
        locality_name, stringr::fixed("*")),
      anesthesia_conv_factor = as.double(anesthesia_conv_factor)
    )
}

anes <- purrr::map(raw_anes, process_anes) |>
  purrr::set_names(
    stringr::str_subset(
      names(raw), "anes") |>
      stringr::str_remove("_anes[0-9]{4}")
  )

rvu_source <- list(
  table  = zip_table |> dplyr::left_join(zip_list, by = dplyr::join_by(file_html)) |> tidyr::nest(sub_files = c(sub_file, sub_file_timestamp)),
  pprrvu = pprrvu,          # Physician Practice Expense Relative Value Units
  oppscap = oppscap,        # Outpatient Prospective Payment System Cap
  gpci = gpci,              # Geographic Practice Cost Indices
  locco = locco,            # Locality
  anes = anes               # Anesthesia
)

pin_update(
  rvu_source,
  name = stringr::str_glue("rvu_source_{year}") |> as.character(),
  title = stringr::str_glue("RVU Source Files {year}") |> as.character()
)

fs::dir_delete(fs::dir_ls("data-raw", regexp = "RVU\\d{2}[A-Z]{0,2}"))
