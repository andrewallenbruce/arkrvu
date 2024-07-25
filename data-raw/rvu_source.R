source(here::here("data-raw", "pins_functions.R"))

download_rvu_info_tables <- function(year) {

  url_land <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

  ## Download 1 ####
  tictoc::tic("Downloading Landing Page")
  html_land <- rvest::read_html(url_land)
  tictoc::toc()

  rvu_table <- rvest::html_table(html_land) |>
    purrr::pluck(1) |>
    dplyr::reframe(year = as.integer(stringr::str_remove_all(Name, "\\D")),
                   filename = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP"))

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

  file_names_url <- strex::str_after_last(rvu_urls, "/")

  link_table <- dplyr::bind_cols(rvu_table, dplyr::tibble(filename_url = file_names_url, url = paste0("https://www.cms.gov", rvu_urls)))

  urls_to_zips <- dplyr::filter(link_table,
                                year == 2024
                                # year == {{  year }}
                                )

  ## Download 2 ####
  tictoc::tic("Downloading Individual Pages")
  html_individual_pgs <- purrr::map(urls_to_zips$url, rvest::read_html)
  tictoc::toc()

  zip_dwnlink <- \(x) {
    x <- rvest::html_elements(x, "a") |>
      rvest::html_attr("href") |>
      collapse::funique() |>
      stringr::str_subset(".zip")

    stringr::str_c("https://www.cms.gov", x)
  }

  zip_download_links <- purrr::map(html_individual_pgs, zip_dwnlink) |> unlist()

  zip_dwninfo <- \(x) {
    rvest::html_elements(x, css = ".field") |>
    rvest::html_text2() |>
    collapse::funique() |>
    stringr::str_subset("Dynamic List", negate = TRUE) |>
    stringr::str_subset("File Name|Description|File Size|Downloads") |>
    stringr::str_replace_all("\\n", " ")
  }

  zip_download_info <- purrr::map(html_individual_pgs, zip_dwninfo) |> purrr::set_names(urls_to_zips$filename_url)

  lookup <- purrr::set_names(1:12, month.name)

  zip_table <- dplyr::tibble(zip_download_links, zip_download_info) |>
    tidyr::unnest(cols = zip_download_info) |>
    dplyr::mutate(col_name = dplyr::case_when(stringr::str_detect(zip_download_info, "File Name") ~ "filename",
                                              stringr::str_detect(zip_download_info, "Description") ~ "description",
                                              stringr::str_detect(zip_download_info, "File Size") ~ "filesize",
                                              stringr::str_detect(zip_download_info, "Downloads") ~ "downloads",
                                              .default = NA_character_),
                  zip_download_info = stringr::str_remove_all(zip_download_info, "File Name |Description |File Size |Downloads ")) |>
    tidyr::pivot_wider(names_from = col_name, values_from = zip_download_info) |>
    dplyr::reframe(file_name = filename,
                   last_updated = stringr::str_extract(downloads, "\\d{2}\\/\\d{2}\\/\\d{4}") |> anytime::anydate(),
                   date_effective = stringr::str_remove_all(description, "Medicare|Physician|Fee|Schedule|rates|effective|-|release") |>
                     stringr::str_squish() |>
                     stringr::str_extract("(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\\s+(\\d{1,2}\\,\\s+)?(\\d{4})"),
                   mon = stringr::str_extract(date_effective, "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"),
                   mon = lookup[mon],
                   day = stringr::str_extract(date_effective, "[0-9]{1,2}(?=,)") |> tidyr::replace_na("1") |> as.integer(),
                   year = stringr::str_extract(date_effective, "\\d{4}$") |> as.integer(),
                   date_effective = clock::date_build(year, mon, day),
                   zip_url = zip_download_links) |>
    dplyr::select(file_name,
                  last_updated,
                  date_effective,
                  zip_url) |>
    dplyr::arrange(date_effective)

  return(zip_table)
}

rvu_links_24 <- download_rvu_info_tables(year = 2024)

zip_table

curl::multi_download(urls = zip_table$zip_url, destfile = here::here("data-raw", stringr::str_glue("{zip_table$file_name}-{basename(zip_table$zip_url)}")))

dataraw <- here::here("data-raw")

zip_paths <- fs::dir_ls(dataraw, glob = "*.zip")

xlsx_names <- zip::zip_list(zipfile = zip_paths[1]) |> dplyr::filter(stringr::str_detect(filename, ".xlsx")) |> dplyr::pull(filename)

zip::unzip(zipfile = zip_paths[1], files = xlsx_names, exdir = dataraw)

raw_rvu24a <- here::here(dataraw, xlsx_names) |>
  purrr::map(readxl::read_excel, col_types = "text") |>
  purrr::map(fuimus::df_2_chr) |>
  purrr::set_names(stringr::str_remove_all(xlsx_names, ".xlsx") |> tolower()) |>
  purrr::map(janitor::clean_names)

# delete zip files ####
fs::file_delete(path = zip_paths)

# PPRRVU ####
#
raw_rvu24a$pprrvu24_jan <- raw_rvu24a$pprrvu24_jan |>
  dplyr::slice(5:dplyr::n()) |>
  unheadr::mash_colnames(n_name_rows = 5, keep_names = FALSE) |>
  janitor::clean_names() |>
  dplyr::filter(!is.na(calculation_flag)) |>
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

# OPPSCAP ####
#
# OPPSCAP contains the payment amounts after the application of the
# OPPS-based payment caps, except for carrier priced codes. For carrier
# price codes, the field only contains the OPPS-based payment caps. Carrier
# prices cannot exceed the OPPS-based payment caps.

raw_rvu24a$oppscap_jan <- raw_rvu24a$oppscap_jan |>
  dplyr::filter(hcpcs != "\u001a") |>
  dplyr::mutate(
    dplyr::across(
      dplyr::contains("price"),
      readr::parse_number)
    ) |>
  dplyr::rename(
    non_facility_price = non_facilty_price
  )

# GPCI ####
#
# ADDENDUM E. FINAL CY 2024 GEOGRAPHIC PRACTICE COST INDICES (GPCIs) BY STATE AND MEDICARE LOCALITY
# https://www.ama-assn.org/system/files/geographic-practice-cost-indices-gpcis.pdf

raw_rvu24a$gpci2024 <- raw_rvu24a$gpci2024 |>
  unheadr::mash_colnames(n_name_rows = 2, keep_names = FALSE) |>
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
    dplyr::across(c(gpci_work, gpci_pe, gpci_mp), readr::parse_number),
    locality_name = stringr::str_remove_all(locality_name, stringr::fixed("*")),
    gpci_gaf = (gpci_work + gpci_pe + gpci_mp) / 3
  )

# LOCCO
#
# counties included in 2024 localities alphabetically
# by state and locality name within state
#
# * = Payment locality is serviced by two carriers.

df_state <- dplyr::tibble(
  state_abb = state.abb,
  state = toupper(state.name)
)

raw_rvu24a$`24locco` <- raw_rvu24a$`24locco` |>
  unheadr::mash_colnames(n_name_rows = 2, keep_names = FALSE) |>
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

raw_rvu24a$locco24   <- raw_rvu24a$`24locco`
raw_rvu24a$`24locco` <- NULL

raw_rvu24a$anes2024 <- raw_rvu24a$anes2024 |>
  janitor::clean_names() |>
  dplyr::reframe(
    contractor,
    locality = fuimus::pad_number(locality),
    locality_name = stringr::str_remove_all(locality_name, stringr::fixed("*")),
    anesthesia_conv_factor = as.double(x2024_anesthesia_conversion_factor)
    )

pin_update(
  raw_rvu24a,
  name = "rvu24a",
  title = "RVU24A January 2024"
)

fs::file_delete(fs::dir_ls(path = dataraw, glob = "*.xlsx"))
