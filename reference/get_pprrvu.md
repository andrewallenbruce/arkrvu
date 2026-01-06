# Get PPRRVU File by Year

Get PPRRVU File by Year

## Usage

``` r
get_pprrvu(dos, hcpcs, pos, ...)
```

## Arguments

- dos:

  `<date>` date of service; YYYY-MM-DD

- hcpcs:

  `<chr>` hcpcs code

- pos:

  `<chr>` place of service; `Facility` or `Non-Facility`

- ...:

  additional arguments

## Value

`<tibble>` containing pprrvu source file

## Examples

``` r
get_pprrvu(dos = "2024-03-31", hcpcs = "99213", pos = "Non-Facility")
#> # A tibble: 1 × 13
#>   date_start date_end   hcpcs mod   description     wrvu  prvu  mrvu  trvu    cf
#>   <date>     <date>     <chr> <chr> <chr>          <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 2024-01-01 2024-03-31 99213 NA    Office o/p es…   1.3  1.33   0.1  2.73  33.3
#> # ℹ 3 more variables: pctc <chr>, glob <chr>, mult <chr>
get_pprrvu(dos = "2024-02-28", hcpcs = "99213", pos = "Facility")
#> # A tibble: 1 × 13
#>   date_start date_end   hcpcs mod   description     wrvu  prvu  mrvu  trvu    cf
#>   <date>     <date>     <chr> <chr> <chr>          <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 2024-01-01 2024-03-31 99213 NA    Office o/p es…   1.3  0.56   0.1  1.96  33.3
#> # ℹ 3 more variables: pctc <chr>, glob <chr>, mult <chr>
```
