#' RVU File Download Links
#'
#' @returns list of selected rvu source files
#'
#' @examples
#' download_links()
#'
#' @export
download_links <- function() {
  get_pin("rvu_link_table")
}

#' Download and Update RVU Link Table
#'
#' @param update_pin `<lgl>` update `"rvu_link_table"` pin; default is `FALSE`
#'
#' @returns RVU Link Table
#'
#' @keywords internal
#'
#' @export
download_link_table <- function(update_pin = FALSE) {
  url_land <- "https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files"

  tictoc::tic("Downloaded RVU File Page")
  html_land <- rvest::read_html(url_land)
  tictoc::toc()

  rvu_table <- rvest::html_table(html_land) |>
    purrr::pluck(1) |>
    dplyr::reframe(
      year = as.integer(stringr::str_remove_all(Name, "\\D")),
      file_html = stringr::str_remove_all(`File Name`, "\\n|File Name|\\s|.ZIP")
    )

  rvu_urls <- rvest::html_elements(html_land, "a") |>
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

  link_table <- dplyr::bind_cols(
    rvu_table,
    dplyr::tibble(
      file_url = strex::str_after_last(rvu_urls, "/"),
      link_url = paste0("https://www.cms.gov", rvu_urls)
    )
  )

  if (update_pin) {
    pin_update <- \(x, name, title) {
      board <- pins::board_folder(here::here("inst/extdata/pins"))
      board |> pins::pin_write(x, name = name, title = title, type = "qs")
      board |> pins::write_board_manifest()
    }

    pin_update(
      link_table,
      name = "rvu_link_table",
      title = "RVU Download Links"
    )
  }
  return(link_table)
}
