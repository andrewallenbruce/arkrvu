# RVU Zip File Download Links

RVU Zip File Download Links

## Usage

``` r
rvu_zip_links(years)
```

## Arguments

- years:

  `<int>` years of RVU source files

## Value

`<tibble>` containing year, file, and date_start, date_end, description,
size and url of RVU zip files

## Examples

``` r
rvu_zip_links()
#> # A tibble: 36 × 7
#>     year file     date_start date_end   description                   size url  
#>  * <int> <chr>    <date>     <date>     <chr>                        <fs:> <chr>
#>  1  2018 RVU18A   2018-01-01 NA         Physician Fee Schedule ? Ja…    3M http…
#>  2  2018 RVU18AR  NA         NA         The following 2018 MPFS inf…  3.4M http…
#>  3  2018 RVU18AR1 NA         2018-03-31 This update includes the re…    3M http…
#>  4  2018 RVU18B   2018-04-01 2018-06-30 Physician Fee Schedule ? Ap…    NA http…
#>  5  2018 RVU18C1  2018-07-01 2018-09-30 Physician Fee Schedule ? Ju…    3M http…
#>  6  2018 RVU18D   2018-10-01 2018-12-31 Posting of October 2018 Med…    NA http…
#>  7  2019 RVU19A   2019-01-01 2019-03-31 Physician Fee Schedule - Ja…    3M http…
#>  8  2019 RVU19B   2019-04-01 2019-06-30 Physician Fee Schedule ? Ap…    3M http…
#>  9  2019 RVU19C   2019-07-01 2019-09-30 Physician Fee Schedule ? Ju…    3M http…
#> 10  2019 RVU19D   2019-10-01 2019-12-31 Physician Fee Schedule - Oc…    3M http…
#> # ℹ 26 more rows
```
