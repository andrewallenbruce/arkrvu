# PPRRVU File by Year

PPRRVU File by Year

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

`<tibble>` containing PPRRVU source file

## Examples

``` r
get_pprrvu("2024-03-31", "99213", "Non-Facility")
#> # A tibble: 18,499 × 13
#>    date_start date_end   hcpcs mod   description    wrvu  prvu  mrvu  trvu    cf
#>    <date>     <date>     <chr> <chr> <chr>         <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 2024-01-01 2024-03-31 A0021 NA    Outside stat…     0     0     0     0  33.3
#>  2 2024-01-01 2024-03-31 A0080 NA    Noninterest …     0     0     0     0  33.3
#>  3 2024-01-01 2024-03-31 A0090 NA    Interest esc…     0     0     0     0  33.3
#>  4 2024-01-01 2024-03-31 A0100 NA    Nonemergency…     0     0     0     0  33.3
#>  5 2024-01-01 2024-03-31 A0110 NA    Nonemergency…     0     0     0     0  33.3
#>  6 2024-01-01 2024-03-31 A0120 NA    Noner transp…     0     0     0     0  33.3
#>  7 2024-01-01 2024-03-31 A0130 NA    Noner transp…     0     0     0     0  33.3
#>  8 2024-01-01 2024-03-31 A0140 NA    Nonemergency…     0     0     0     0  33.3
#>  9 2024-01-01 2024-03-31 A0160 NA    Noner transp…     0     0     0     0  33.3
#> 10 2024-01-01 2024-03-31 A0170 NA    Transport pa…     0     0     0     0  33.3
#> # ℹ 18,489 more rows
#> # ℹ 3 more variables: pctc <chr>, glob <chr>, mult <chr>
get_pprrvu("2024-02-28", "99213", "Facility")
#> # A tibble: 18,499 × 13
#>    date_start date_end   hcpcs mod   description    wrvu  prvu  mrvu  trvu    cf
#>    <date>     <date>     <chr> <chr> <chr>         <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 2024-01-01 2024-03-31 A0021 NA    Outside stat…     0     0     0     0  33.3
#>  2 2024-01-01 2024-03-31 A0080 NA    Noninterest …     0     0     0     0  33.3
#>  3 2024-01-01 2024-03-31 A0090 NA    Interest esc…     0     0     0     0  33.3
#>  4 2024-01-01 2024-03-31 A0100 NA    Nonemergency…     0     0     0     0  33.3
#>  5 2024-01-01 2024-03-31 A0110 NA    Nonemergency…     0     0     0     0  33.3
#>  6 2024-01-01 2024-03-31 A0120 NA    Noner transp…     0     0     0     0  33.3
#>  7 2024-01-01 2024-03-31 A0130 NA    Noner transp…     0     0     0     0  33.3
#>  8 2024-01-01 2024-03-31 A0140 NA    Nonemergency…     0     0     0     0  33.3
#>  9 2024-01-01 2024-03-31 A0160 NA    Noner transp…     0     0     0     0  33.3
#> 10 2024-01-01 2024-03-31 A0170 NA    Transport pa…     0     0     0     0  33.3
#> # ℹ 18,489 more rows
#> # ℹ 3 more variables: pctc <chr>, glob <chr>, mult <chr>
```
