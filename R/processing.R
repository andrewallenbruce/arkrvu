#' Process RVU Zip File Link Table
#'
#' Processes the downloaded table of RVU source zip file links from the CMS
#' website. Used internally to populate and update the `rvu_zip_links` dataset.
#'
#' @param x `<data.frame>` output of [download_rvu_zip_links()]
#'
#' @returns `<tibble>` containing information about RVU source files
#'
#' @examplesIf FALSE
#' parse_rvu_zip_links(download_rvu_zip_links(2024))
#'
#' @keywords internal
#'
#' @export
parse_rvu_zip_links <- function(x) {
  x <- purrr::map(x, \(x) {
    fastplyr::new_tbl(
      url = stringr::str_c(
        "https://www.cms.gov",
        rvest::html_elements(x, css = "a") |>
          rvest::html_attr("href") |>
          collapse::funique() |>
          stringr::str_subset(".zip") |>
          stringr::str_remove(stringr::fixed(" /apps/ama/license.asp?file="))
      ),
      info = rvest::html_elements(x, css = ".field") |>
        rvest::html_text2() |>
        collapse::funique() |>
        stringr::str_subset("Dynamic List", negate = TRUE) |>
        stringr::str_subset("File Name|Description|File Size|Downloads") |>
        stringr::str_replace_all("\\n", " ")
    ) |>
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
      collapse::pivot(
        names = "col_name",
        values = "info",
        how = "wider"
      )
  }) |>
    collapse::rowbind(fill = TRUE)

  month_name <- rlang::set_names(1:12, month.name)
  start_rex <- "Medicare|Physician|Fee|Schedule|rates|effective|-|release"
  month_rex <- "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"
  mdate_rex <- "\\s+(\\d{1,2}\\,\\s+)?(\\d{4})"

  x |>
    collapse::mtt(
      date_start = stringr::str_squish(stringr::str_remove_all(
        description,
        stringr::regex(start_rex)
      )) |>
        stringr::str_extract(stringr::regex(paste0(month_rex, mdate_rex))),
      mon = month_name[stringr::str_extract(date_start, month_rex)],
      day = stringr::str_extract(date_start, stringr::regex("[0-9]{1,2}(?=,)")),
      day = strtoi(cheapr::if_else_(cheapr::is_na(day), "1", day)),
      year = strtoi(stringr::str_extract(
        date_start,
        stringr::regex("\\d{4}$")
      )),
      date_start = clock::date_build(year, mon, day)
    ) |>
    collapse::slt(
      year,
      file,
      date_start,
      url,
      description
    ) |>
    fastplyr::f_arrange(file, fastplyr::desc(date_start))
}
