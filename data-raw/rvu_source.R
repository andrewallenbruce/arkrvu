download_rvu_info_tables <- function(year) {

  url_land <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

  html_land <- rvest::read_html(url_land)

  rvu_table <- rvest::html_table(html_land) |>
    purrr::pluck(1) |>
    dplyr::reframe(
      year = as.integer(
        stringr::str_remove_all(Name, "\\D")
        ),
      filename = stringr::str_remove_all(
        `File Name`,
        "\\n|File Name|\\s|.ZIP"
        )
    )

  rvu_urls <- html_land |>
    rvest::html_elements("a") |>
    rvest::html_attr("href") |>
    collapse::funique() |>
    stringr::str_subset(
      stringr::regex(
        paste(
          "/medicare/payment/fee-schedules/physician/pfs-relative-value-files/",
          "/medicare/medicare-fee-service-payment/physicianfeesched/pfs-relative-value-files/",
          "/medicaremedicare-fee-service-paymentphysicianfeeschedpfs-relative-value-files/",
          "/medicare/medicare-fee-for-service-payment/physicianfeesched/pfs-relative-value-files-items/",
          sep = "|"
        )
      )
    )

  file_names_url <- strex::str_after_last(rvu_urls, "/")

  link_table <- dplyr::bind_cols(
    rvu_table,
    dplyr::tibble(
      filename_url = file_names_url,
      url = paste0("https://www.cms.gov", rvu_urls)
    )
  )

  urls_to_zips <- dplyr::filter(link_table, year == {{  year }})

  html_individual_pgs <- purrr::map(urls_to_zips$url, rvest::read_html)

  zip_download_links <- purrr::map(
    html_individual_pgs,
    rvest::html_elements, css = "a") |>
    purrr::map(rvest::html_attr, "href") |>
    purrr::map(collapse::funique) |>
    purrr::map(stringr::str_subset, ".zip") |>
    purrr::map(\(x) stringr::str_c("https://www.cms.gov", x)) |>
    unlist()

  zip_download_info <- purrr::map(html_individual_pgs, rvest::html_elements, css = ".field") |>
    purrr::map(rvest::html_text2) |>
    purrr::map(collapse::funique) |>
    purrr::map(stringr::str_subset, "Dynamic List", TRUE) |>
    purrr::map(stringr::str_subset, "File Name|Description|File Size|Downloads") |>
    purrr::map(stringr::str_replace_all, "\\n", " ") |>
    purrr::set_names(urls_to_zips$filename_url)

  lookup <- purrr::set_names(1:12, month.name)

  zip_table <- dplyr::tibble(
    zip_download_links,
    zip_download_info
  ) |>
    tidyr::unnest(cols = zip_download_info) |>
    dplyr::mutate(
      col_name = dplyr::case_when(
        stringr::str_detect(zip_download_info, "File Name") ~ "filename",
        stringr::str_detect(zip_download_info, "Description") ~ "description",
        stringr::str_detect(zip_download_info, "File Size") ~ "filesize",
        stringr::str_detect(zip_download_info, "Downloads") ~ "downloads",
        .default = NA_character_
      ),
      zip_download_info = stringr::str_remove_all(
        zip_download_info,
        "File Name |Description |File Size |Downloads ")) |>
    tidyr::pivot_wider(
      names_from = col_name,
      values_from = zip_download_info) |>
    dplyr::reframe(
      file_name = filename,
      last_updated = stringr::str_extract(downloads, "\\d{2}\\/\\d{2}\\/\\d{4}") |> anytime::anydate(),
      date_effective = stringr::str_remove_all(description, "Medicare|Physician|Fee|Schedule|rates|effective|-|release") |>
        stringr::str_squish() |>
        stringr::str_extract("(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\\s+(\\d{1,2}\\,\\s+)?(\\d{4})"),
      mon = stringr::str_extract(date_effective, "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"),
      mon = lookup[mon],
      day = stringr::str_extract(date_effective, "[0-9]{1,2}(?=,)") |> tidyr::replace_na("1") |> as.integer(),
      year = stringr::str_extract(date_effective, "\\d{4}$") |> as.integer(),
      date_effective = clock::date_build(year, mon, day),
      zip_url = zip_download_links
    ) |>
    dplyr::select(
      file_name,
      last_updated,
      date_effective,
      zip_url
    )

  return(zip_table)

}

curl::multi_download(rvu_prefix)

xlsx_filename <- zip::zip_list(
  fs::dir_ls(glob = "*c.zip")) |>
  filter(str_detect(filename, ".xlsx")) |>
  pull(filename)

zip::unzip(fs::dir_ls(glob = "*c.zip"),
           files = xlsx_filename)

rvu_files <- here::here(xlsx_filename) |>
  purrr::map(readxl::read_excel, col_types = "text") |>
  purrr::map(fuimus::df_2_chr) |>
  purrr::set_names(stringr::str_remove_all(xlsx_filename, ".xlsx")) |>
  purrr::map(janitor::clean_names)

fs::file_delete(here::here(fs::dir_ls(glob = "*.zip")))
