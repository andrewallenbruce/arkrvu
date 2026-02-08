process_zip_links <- function(x) {
  lookup <- rlang::set_names(1:12, month.name)

  zip_link <- function(x) {
    x <- rvest::html_elements(x, css = "a") |>
      rvest::html_attr("href") |>
      collapse::funique() |>
      stringr::str_subset(".zip")

    stringr::str_c("https://www.cms.gov", x)
  }

  zip_info <- function(x) {
    rvest::html_elements(x, css = ".field") |>
      rvest::html_text2() |>
      collapse::funique() |>
      stringr::str_subset("Dynamic List", negate = TRUE) |>
      stringr::str_subset("File Name|Description|File Size|Downloads") |>
      stringr::str_replace_all("\\n", " ")
  }

  x <- purrr::map(x, \(x) {
    x <- fastplyr::new_tbl(
      url = zip_link(x),
      info = zip_info(x)
    )

    x <- x |>
      collapse::mtt(
        col_name = cheapr::case(
          stringr::str_detect(info, "File Name") ~ "file",
          stringr::str_detect(info, "Description") ~ "description",
          stringr::str_detect(info, "File Size") ~ "size",
          stringr::str_detect(info, "Downloads") ~ "updated",
          .default = NA_character_
        ),
        info = stringr::str_remove_all(
          info,
          "File Name |Description |File Size |Downloads "
        )
      ) |>
      tidyr::pivot_wider(
        names_from = col_name,
        values_from = info
      )

    x <- x |>
      collapse::mtt(
        date_start = stringr::str_remove_all(
          description,
          "Medicare|Physician|Fee|Schedule|rates|effective|-|release"
        ) |>
          stringr::str_squish() |>
          stringr::str_extract(
            "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\\s+(\\d{1,2}\\,\\s+)?(\\d{4})"
          ),
        mon = lookup[stringr::str_extract(
          date_start,
          "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"
        )],
        day = stringr::str_extract(date_start, "[0-9]{1,2}(?=,)") |>
          tidyr::replace_na("1") |>
          strtoi(),
        year = stringr::str_extract(date_start, "\\d{4}$") |> strtoi(),
        date_start = clock::date_build(year, mon, day),
        size = fs::as_fs_bytes(size)
      )
    return(x)
  })

  x |>
    collapse::rowbind(fill = TRUE) |>
    collapse::slt(
      year,
      file,
      date_start,
      size,
      url,
      description
    ) |>
    fastplyr::f_arrange(file, fastplyr::desc(date_start))
}

download_rvu_zips <- function(zip_table, directory = "D:/MPFS Files Archive/") {
  zip_paths <- stringr::str_glue(
    "{directory}{zip_table$file_html}-{basename(zip_table$zip_link)}"
  )

  curl::multi_download(
    urls = zip_table$zip_link,
    destfile = zip_paths,
    resume = TRUE,
    multi_timeout = Inf
  )
  return(zip_paths)
}

unpack_rvu_zips <- function(
  zip_paths,
  directory = "D:/MPFS Files Archive/unzipped/"
) {
  zip_list_table <- purrr::map(zip_paths, zip::zip_list) |>
    purrr::set_names(stringr::str_extract(
      basename(zip_paths),
      "^RVU[0-9]{2}[A-Z]{0,2}"
    )) |>
    purrr::list_rbind(names_to = "file_html") |>
    dplyr::tibble() |>
    dplyr::select(
      file_html,
      sub_file = filename,
      sub_file_timestamp = timestamp
    ) |>
    dplyr::filter(grepl(".xlsx", sub_file))

  unzip_args <- list(
    zipfile = zip_paths,
    exdir = paste0(
      directory,
      collapse::funique(dplyr::pull(zip_list_table, file_html))
    )
  )

  purrr::pwalk(unzip_args, zip::unzip)

  fs::file_delete(path = zip_paths)

  return(zip_list_table)
}

process_raw_xlsx <- function() {
  rvu_folders <- fs::dir_ls(here::here("data-raw"), regexp = "RVU")
  rvu_folder_names <- basename(rvu_folders)
  rvu_xlsx_files <- fs::dir_ls(rvu_folders, glob = "*.xlsx")
  rvu_setnames <- stringr::str_remove_all(rvu_xlsx_files, ".xlsx") |>
    strex::str_after_nth("/", -2) |>
    stringr::str_replace("/", "_") |>
    tolower()

  rvu_xlsx_files |>
    purrr::map(readxl::read_excel, col_types = "text") |>
    purrr::map(fuimus::df_2_chr) |>
    purrr::set_names(rvu_setnames)
}

create_list <- function(raw, list, remove) {
  names <- stringr::str_subset(names(raw), list)
  raw_to_string <- stringr::str_c(
    stringr::str_glue("raw${names}"),
    collapse = ", "
  )
  string_to_list <- stringr::str_c("list(", raw_to_string, ")")
  list_to_df <- rlang::eval_tidy(rlang::parse_expr(string_to_list))
  list_to_df |> purrr::set_names(stringr::str_remove(names, remove))
}

process_pprrvu <- function(x) {
  dplyr::slice(x, 5:dplyr::n()) |>
    unheadr::mash_colnames(n_name_rows = 5, keep_names = FALSE) |>
    janitor::clean_names() |>
    dplyr::filter(!is.na(calculation_flag)) |>
    dplyr::mutate(
      dplyr::across(
        c(
          dplyr::contains("rvu"),
          dplyr::contains("total"),
          dplyr::contains("_op"),
          conv_factor
        ),
        readr::parse_number
      )
    )
}

process_oppscap <- function(x) {
  dplyr::filter(x, HCPCS != "\u001a") |>
    janitor::clean_names() |>
    dplyr::mutate(
      dplyr::across(
        dplyr::contains("price"),
        readr::parse_number
      )
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
        locality_name,
        stringr::fixed("*")
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
        locality_name,
        stringr::fixed("*")
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
      fee_schedule_area = stringr::str_remove_all(
        fee_schedule_area,
        stringr::fixed("*")
      ),
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
      fee_schedule_area = stringr::str_remove_all(
        fee_schedule_area,
        stringr::fixed("*")
      ),
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
        locality
      ),
      locality_name = stringr::str_remove_all(
        locality_name,
        stringr::fixed("*")
      ),
      anesthesia_conv_factor = as.double(anesthesia_conv_factor)
    )
}
