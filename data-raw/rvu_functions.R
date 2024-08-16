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

  tictoc::tic(
    stringr::str_glue(
      "Downloaded {length(selected_urls)} Pages"
      )
    )

  rvu_pgs <- purrr::map(
    selected_urls,
    rvest::read_html,
    .progress = stringr::str_glue(
      "Downloading {length(selected_urls)} Pages"
      )
    )

  tictoc::toc()

  return(rvu_pgs)
}

process_rvu_pages <- function(rvu_pages, link_table, year) {

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

  zip_paths <- here::here(
    directory,
    stringr::str_glue(
      "{zip_table$file_html}-{basename(zip_table$zip_link)}"
      )
    )

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

process_raw_xlsx <- function() {

  rvu_folders      <- fs::dir_ls(here::here("data-raw"), regexp = "RVU")
  rvu_folder_names <- basename(rvu_folders)
  rvu_xlsx_files   <- fs::dir_ls(rvu_folders, glob = "*.xlsx")
  rvu_setnames     <- stringr::str_remove_all(rvu_xlsx_files, ".xlsx") |>
    strex::str_after_nth("/", -2) |>
    stringr::str_replace("/", "_") |>
    tolower()

  rvu_xlsx_files |>
    purrr::map(readxl::read_excel, col_types = "text") |>
    purrr::map(fuimus::df_2_chr) |>
    purrr::set_names(rvu_setnames)
}

create_list <- function(raw, list, remove) {

  names <- stringr::str_subset(
    names(raw), list)

  raw_to_string <- stringr::str_c(
    stringr::str_glue("raw${names}"),
    collapse = ", ")

  string_to_list <- stringr::str_c(
    "list(", raw_to_string, ")")

  list_to_df <- rlang::eval_tidy(
    rlang::parse_expr(string_to_list)
    )

  list_to_df |> purrr::set_names(
    stringr::str_remove(names, remove)
    )
}

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

# starts at 2020 -- no more state names ####
process_gpci2 <- function(x) {

  x <- unheadr::mash_colnames(
    x,
    n_name_rows = 1,
    keep_names = FALSE
  ) |>
    janitor::clean_names()

  # |> dplyr::filter(!is.na(state))

  names(x) <- c(
    "mac",
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

# 2021-Present ####
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

# starts at 2020 -- medicare_adminstrative_contractor is now carrier_number ####
process_locco2 <- function(x) {

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
    dplyr::filter(!is.na(carrier_number)) |>
    tidyr::fill(state) |>
    dplyr::reframe(
      mac = carrier_number,
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

# 2021-Present ####
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
