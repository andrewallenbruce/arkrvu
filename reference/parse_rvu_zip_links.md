# Process RVU Zip File Link Table

Processes the downloaded table of RVU source zip file links from the CMS
website. Used internally to populate and update the `rvu_zip_links`
dataset.

## Usage

``` r
parse_rvu_zip_links(x)
```

## Arguments

- x:

  `<data.frame>` output of
  [`download_rvu_zip_links()`](https://andrewallenbruce.github.io/arkrvu/reference/download_rvu_zip_links.md)

## Value

`<tibble>` containing information about RVU source files

## Examples

``` r
if (FALSE) {
parse_rvu_zip_links(download_rvu_zip_links(2024))
}
```
