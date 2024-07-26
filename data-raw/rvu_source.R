source(here::here("data-raw", "pins_functions.R"))

download_link_table <- function() {

  url_land <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

  tictoc::tic("Downloaded RVU File Page")
  html_land <- rvest::read_html(url_land)
  tictoc::toc()

  rvu_table <- rvest::html_table(html_land) |>
    purrr::pluck(1) |>
    dplyr::reframe(year = as.integer(stringr::str_remove_all(Name, "\\D")),
                   file_html = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP"))

  rvu_urls <- rvest::html_elements(html_land, "a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset(stringr::regex(
      paste(
        "/medicare/payment/fee-schedules/physician/pfs-relative-value-files/",
        "/medicare/medicare-fee-service-payment/physicianfeesched/pfs-relative-value-files/",
        "/medicaremedicare-fee-service-paymentphysicianfeeschedpfs-relative-value-files/",
        "/medicare/medicare-fee-for-service-payment/physicianfeesched/pfs-relative-value-files-items/",
        sep = "|"
      )))

  dplyr::bind_cols(
    rvu_table,
    dplyr::tibble(
      file_url = strex::str_after_last(rvu_urls, "/"),
      link_url = paste0("https://www.cms.gov", rvu_urls)
    ))
}

download_rvu_pages <- function(link_table, year = NULL) {

  if (!is.null(year)) {

    selected_urls <- dplyr::filter(
      link_table,
      year == {{  year }}
    ) |>
      dplyr::pull(link_url)

  } else {

    selected_urls <- dplyr::pull(link_table, link_url)

  }

  tictoc::tic(stringr::str_glue("Downloaded {length(selected_urls)} Pages"))

  rvu_pgs <- purrr::map(
    selected_urls,
    rvest::read_html,
    .progress = stringr::str_glue("Downloading {length(selected_urls)} Pages")
    )

  tictoc::toc()

  return(rvu_pgs)
}

process <- list(
    zip_link = \(x) {
      link <- rvest::html_elements(x, css = "a") |>
        rvest::html_attr("href") |>
        collapse::funique() |>
        stringr::str_subset(".zip")

      stringr::str_c("https://www.cms.gov", link)
    },

    zip_info = \(x) {
      rvest::html_elements(x, css = ".field") |>
        rvest::html_text2() |>
        collapse::funique() |>
        stringr::str_subset("Dynamic List", negate = TRUE) |>
        stringr::str_subset("File Name|Description|File Size|Downloads") |>
        stringr::str_replace_all("\\n", " ")
    },

    lookup = purrr::set_names(1:12, month.name)
  )

process_rvu_pages <- function(rvu_pages, link_table, year) {

  dplyr::tibble(
    zip_link = purrr::map(
      rvu_pages,
      process$zip_link) |>
      unlist(),
    zip_info = purrr::map(
      rvu_pages,
      process$zip_info) |>
      purrr::set_names(
        link_table[link_table$year == year, 3, drop = TRUE]
        )
    ) |>
    tidyr::unnest(cols = zip_info) |>
    dplyr::mutate(
      col_name = dplyr::case_when(
        stringr::str_detect(zip_info, "File Name") ~ "filename",
        stringr::str_detect(zip_info, "Description") ~ "description",
        stringr::str_detect(zip_info, "File Size") ~ "filesize",
        stringr::str_detect(zip_info, "Downloads") ~ "downloads",
        .default = NA_character_),
      zip_info = stringr::str_remove_all(
        zip_info,
        "File Name |Description |File Size |Downloads "
        )
      ) |>
    tidyr::pivot_wider(
      names_from = col_name,
      values_from = zip_info
      ) |>
    dplyr::reframe(
      file_html = filename,
      last_updated = stringr::str_extract(
        downloads, "\\d{2}\\/\\d{2}\\/\\d{4}"
        ) |>
        anytime::anydate(),
      date_effective = stringr::str_remove_all(
        description,
        "Medicare|Physician|Fee|Schedule|rates|effective|-|release"
        ) |>
        stringr::str_squish() |>
        stringr::str_extract(
          "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\\s+(\\d{1,2}\\,\\s+)?(\\d{4})"
          ),
      mon = stringr::str_extract(
        date_effective,
        "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"
        ),
      mon = process$lookup[mon],
      day = stringr::str_extract(
        date_effective,
        "[0-9]{1,2}(?=,)"
        ) |>
        tidyr::replace_na("1") |>
        as.integer(),
      year = stringr::str_extract(
        date_effective,
        "\\d{4}$"
        ) |>
        as.integer(),
      date_effective = clock::date_build(year, mon, day),
      zip_link
      ) |>
    dplyr::select(
      file_html,
      date_effective,
      last_updated,
      zip_link
      ) |>
    dplyr::arrange(date_effective)
}

download_rvu_zips <- function(zip_table, directory = "data-raw") {

  zip_paths <- here::here(directory,
    stringr::str_glue(
      "{zip_table$file_html}-{basename(zip_table$zip_link)}"
      ))

  curl::multi_download(
    urls = zip_table$zip_link,
    destfile = zip_paths,
    resume = TRUE,
    timeout = 60
    )

  return(zip_paths)
}

unpack_rvu_zips <- function(zip_paths, directory = "data-raw") {

  zip_list_table <- purrr::map(
    zip_paths,
    zip::zip_list
  ) |>
    purrr::set_names(
      stringr::str_extract(
        basename(zip_paths),
        "^RVU[0-9]{2}[A-Z]{0,2}"
      )
    ) |>
    purrr::list_rbind(
      names_to = "file_html"
    ) |>
    dplyr::tibble() |>
    dplyr::select(
      file_html,
      sub_file = filename,
      sub_file_timestamp = timestamp
    ) |>
    dplyr::filter(
      grepl(".xlsx", sub_file)
    )

  unzip_args <- list(
    zipfile = zip_paths,
    exdir = here::here(
      directory,
      unique(
        dplyr::pull(
          zip_list_table,
          file_html
        )
      )
    )
  )

  purrr::pwalk(unzip_args, zip::unzip)

  fs::file_delete(path = zip_paths)

  return(zip_list_table)
}

link_table <- download_link_table()
rvu_pages  <- download_rvu_pages(link_table, year = 2024)
zip_table  <- process_rvu_pages(rvu_pages, link_table, year = 2024)
zip_paths  <- download_rvu_zips(zip_table, directory = "data-raw")
zip_list   <- unpack_rvu_zips(zip_paths, directory = "data-raw")


rvu_folders      <- fs::dir_ls(here::here("data-raw"), regexp = "RVU")
rvu_folder_names <- basename(rvu_folders)
rvu_xlsx_files   <- fs::dir_ls(rvu_folders, glob = "*.xlsx")

rvu_setnames <- stringr::str_remove_all(
  rvu_xlsx_files,
  ".xlsx"
  ) |>
  strex::str_after_nth("/", -2) |>
  stringr::str_replace("/", "_") |>
  tolower()


raw <- rvu_xlsx_files |>
  purrr::map(readxl::read_excel, col_types = "text") |>
  purrr::map(fuimus::df_2_chr) |>
  purrr::set_names(rvu_setnames)

# PPRRVU ####

raw_pprvu_24 <- list(
  raw$rvu24a_pprrvu24_jan,
  raw$rvu24ar_pprrvu24_jan,
  raw$rvu24b_pprrvu24_apr,
  raw$rvu24c_pprrvu24_jul
)

process_pprvu <- function(x) {

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
          dplyr::contains("_surg"),
          dplyr::contains("_op"),
          conv_factor
        ),
        readr::parse_number)
    )

}

pprvu <- purrr::map(raw_pprvu_24, process_pprvu) |>
  purrr::set_names(
    c(
      "rvu24a_jan",
      "rvu24ar_jan",
      "rvu24b_apr",
      "rvu24c_jul"
      )
    )

pprvu

# OPPSCAP ####
#
# OPPSCAP contains the payment amounts after the application of the
# OPPS-based payment caps, except for carrier priced codes. For carrier
# price codes, the field only contains the OPPS-based payment caps. Carrier
# prices cannot exceed the OPPS-based payment caps.

raw_oppscap_24 <- list(
  raw$rvu24a_oppscap_jan,
  raw$rvu24ar_oppscap_jan,
  raw$rvu24b_oppscap_apr,
  raw$rvu24c_oppscap_jul
)

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

oppscap <- purrr::map(raw_oppscap_24, process_oppscap) |>
  purrr::set_names(
    c(
      "rvu24a_jan",
      "rvu24ar_jan",
      "rvu24b_apr",
      "rvu24c_jul"
    )
  )

oppscap

# GPCI ####
#
# ADDENDUM E. FINAL CY 2024 GEOGRAPHIC PRACTICE COST INDICES (GPCIs) BY STATE AND MEDICARE LOCALITY
# https://www.ama-assn.org/system/files/geographic-practice-cost-indices-gpcis.pdf

raw_gpci_24 <- list(
  raw$rvu24a_gpci2024,
  raw$rvu24ar_gpci2024,
  raw$rvu24b_gpci2024,
  raw$rvu24c_gpci2024
)

process_gpci <- function(x) {

  unheadr::mash_colnames(
    x,
    n_name_rows = 2,
    keep_names = FALSE
    ) |>
    janitor::clean_names() |>
    dplyr::filter(!is.na(state)) |>
    dplyr::reframe(
      mac = medicare_administrative_contractor_mac,
      state,
      locality_number,
      locality_name,
      gpci_work = x2024_pw_gpci_with_1_0_floor,
      gpci_pe = x2024_pe_gpci,
      gpci_mp = x2024_mp_gpci
    ) |>
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

gpci <- purrr::map(raw_gpci_24, process_gpci) |>
  purrr::set_names(
    c(
      "rvu24a",
      "rvu24ar",
      "rvu24b",
      "rvu24c"
    )
  )

gpci

# LOCCO
#
# counties included in 2024 localities alphabetically
# by state and locality name within state
#
# * = Payment locality is serviced by two carriers.

raw_locco_24 <- list(
  raw$rvu24a_24locco,
  raw$rvu24ar_24locco,
  raw$rvu24b_24locco,
  raw$rvu24c_24locco
)

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

locco <- purrr::map(raw_locco_24, process_locco) |>
  purrr::set_names(
    c(
      "rvu24a",
      "rvu24ar",
      "rvu24b",
      "rvu24c"
    )
  )

# ANES2024 ####
raw_anes_24 <- list(
  raw$rvu24a_anes2024,
  raw$rvu24ar_anes2024,
  raw$rvu24b_anes2024,
  raw$rvu24c_anes2024
)

process_anes <- function(x) {
  x |>
  janitor::clean_names() |>
    dplyr::reframe(
      contractor,
      locality = dplyr::if_else(
        stringr::str_length(locality) != 2,
        stringr::str_pad(locality, 2, pad = "0"),
        locality),
      locality_name = stringr::str_remove_all(locality_name, stringr::fixed("*")),
      anesthesia_conv_factor = as.double(x2024_anesthesia_conversion_factor)
    )
}

anes <- purrr::map(raw_anes_24, process_anes) |>
  purrr::set_names(
    c(
      "rvu24a",
      "rvu24ar",
      "rvu24b",
      "rvu24c"
    )
  )

rvu_source_2024 <- list(
  link_table = link_table,    # RVU zip files available for download
  zip_table  = zip_table,     # RVU zip files that have been downloaded
  zip_list   = zip_list_table, # RVU files that have been unzipped
  files = list(
    pprvu = pprvu,            # Physician Practice Expense Relative Value Units
    oppscap = oppscap,        # Outpatient Prospective Payment System Cap
    gpci = gpci,              # Geographic Practice Cost Indices
    locco = locco,            # Locality
    anes = anes               # Anesthesia
  )
)

pin_update(
  rvu_source_2024,
  name = "rvu_source_2024",
  title = "RVU Source Files 2024"
)

fs::dir_delete(fs::dir_ls("data-raw", regexp = "RVU\\d{2}[A-Z]{0,2}"))
