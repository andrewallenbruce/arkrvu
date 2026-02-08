# Download RVU Zip File Link Table

Downloads the table of RVU source zip file links from the CMS website.
Used internally to populate and update the `rvu_zip_links` dataset.

## Usage

``` r
download_rvu_zip_links(years)
```

## Arguments

- years:

  `<int>` year(s) of RVU source file, available in
  [`rvu_link_table()`](https://andrewallenbruce.github.io/arkrvu/reference/link_tables.md)

## Value

`<tibble>` containing year, file, and url of RVU source files

## Examples

``` r
if (FALSE) {
download_rvu_zip_links(years = 2024)
}
```
