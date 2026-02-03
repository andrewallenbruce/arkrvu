# Make a date object

Make a date object

## Usage

``` r
make_date(y, m = 1L, d = 1L, ...)
```

## Arguments

- y:

  `<integer>` year

- m:

  `<integer>` month, default is `1L`

- d:

  `<integer>` day, default is `1L`

- ...:

  additional arguments passed to
  [`clock::date_build()`](https://clock.r-lib.org/reference/date_build.html)

## Value

`<Date>` date object

## Examples

``` r
make_date(2015:2025)
#>  [1] "2015-01-01" "2016-01-01" "2017-01-01" "2018-01-01" "2019-01-01"
#>  [6] "2020-01-01" "2021-01-01" "2022-01-01" "2023-01-01" "2024-01-01"
#> [11] "2025-01-01"
make_date(2010, 6, 1)
#> [1] "2010-06-01"
```
