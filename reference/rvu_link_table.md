# RVU File Download Links

RVU File Download Links

## Usage

``` r
rvu_link_table(years)
```

## Arguments

- years:

  `<int>` years of RVU source files

## Value

`<tibble>` containing year, file, and url of RVU source files

## Examples

``` r
rvu_link_table()
#> # A tibble: 107 × 3
#>     year file    url                                                            
#>    <int> <chr>   <chr>                                                          
#>  1  2026 RVU26A  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  2  2025 RVU25A  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  3  2025 RVU25B  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  4  2025 RVU25C  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  5  2025 RVU25D  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  6  2024 RVU24A  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  7  2024 RVU24B  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  8  2024 RVU24AR https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#>  9  2024 RVU24C  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#> 10  2024 RVU24D  https://www.cms.gov/medicare/payment/fee-schedules/physician/p…
#> # ℹ 97 more rows
```
