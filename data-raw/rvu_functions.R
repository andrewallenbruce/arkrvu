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
