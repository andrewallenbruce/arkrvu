url_to_scrape <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

url_to_click <- rvest::read_html(url_to_scrape)

rvu_table <- rvest::html_table(url_to_click) |>
  purrr::pluck(1) |>
  dplyr::reframe(
    year = as.integer(stringr::str_remove_all(Name, "\\D")),
    name_file = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP")
  )

rvu_urls <- url_to_click |>
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

url_names <- rvu_urls |> strex::str_after_last("/")

link_table <- dplyr::bind_cols(
  rvu_table,
  dplyr::tibble(
    name_url = url_names,
    url = paste0("https://www.cms.gov", rvu_urls)
  )
)


urls_to_zips <- dplyr::filter(link_table, year == 2024)

download_pages <- purrr::map(urls_to_zips$url, rvest::read_html)

purrr::map(download_pages, rvest::html_elements, css = ".field") |>
  purrr::map(rvest::html_text2) |>
  purrr::map(collapse::funique) |>
  purrr::map(stringr::str_subset, "Dynamic List", TRUE)


download_zips <- purrr::map(download_pages, rvest::html_elements, css = "a") |>
  purrr::map(rvest::html_attr, "href") |>
  purrr::map(collapse::funique) |>
  purrr::map(stringr::str_subset, ".zip") |>
  purrr::map(\(x) stringr::str_c("https://www.cms.gov", x)) |>
  unlist()


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
