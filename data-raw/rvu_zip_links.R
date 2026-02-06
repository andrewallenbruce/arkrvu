x <- download_rvu_pages(year = c(2026, 2025))
x
zip_links_25_26 <- process_rvu_pages(x) |>
  collapse::mtt(
    date_start = cheapr::if_else_(
      file == "RVU25D",
      make_date(2025, 10, 1),
      date_start
    )
  )

y <- download_rvu_pages(year = 2024)
y
zip_links_24 <- process_rvu_pages(y)

z <- download_rvu_pages(year = 2023)
z
zip_links_23 <- process_rvu_pages(z)
zip_links_23

rvu_zip_links <- vctrs::vec_rbind(
  zip_links_25_26,
  zip_links_24
) |>
  collapse::slt(-updated) |>
  collapse::roworder(year, file) |>
  collapse::mtt(date_end = cheapr::lag_(date_start, -1L) - 1L) |>
  collapse::colorder(
    year,
    file,
    date_start,
    date_end,
    description,
    size,
    zip_link
  ) |>
  collapse::frename(
    url = zip_link
  )

pin_update(
  rvu_zip_links,
  name = "rvu_zip_links",
  title = "RVU Zip File Links",
  description = "RVU Zip File Links from CMS.gov"
)
