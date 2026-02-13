to_na <- function(x) cheapr::if_else_(x == "9", NA_character_, x)

bin_ <- function(x) cheapr::if_else_(cheapr::is_na(x), 0L, 1L)

glob_ <- function(x) {
  cheapr::val_match(
    x,
    "000" ~ "0",
    "010" ~ "1",
    "090" ~ "9",
    "MMM" ~ "M",
    "XXX" ~ NA_character_,
    "YYY" ~ "Y",
    "ZZZ" ~ "Z",
    .default = NA_character_
  )
}

diag_ <- function(x) cheapr::if_else_(x == "88", "1", NA_character_)

classify_hcpcs <- function(x) {
  collapse::mtt(
    x,
    level = hcpcs_level(hcpcs),
    level = cheapr::if_else_(
      level == "HCPCS I",
      cpt_category(hcpcs),
      level
    ),
    section = cheapr::if_else_(
      level != "HCPCS II",
      cpt_section(hcpcs),
      hcpcs_section(hcpcs)
    )
  ) |>
    collapse::colorder(
      hcpcs,
      level,
      section
    )
}

add_zip_link <- function(df) {
  fastplyr::f_bind_rows(
    get_pin("rvu_zip_links"),
    df
  ) |>
    fastplyr::f_arrange(year, date_start) |>
    collapse::mtt(
      date_end = cheapr::if_else_(
        cheapr::is_na(date_end),
        cheapr::lag_(date_start, -1L) - 1L,
        date_end
      )
    ) |>
    collapse::colorder(
      year,
      file,
      date_start,
      date_end,
      description,
      url
    )
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
