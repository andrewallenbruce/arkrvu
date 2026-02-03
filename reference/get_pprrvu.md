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
get_pprrvu(dos = "2024-03-31", hcpcs = "99213", pos = "Non-Facility")
#> # A tibble: 1 × 34
#>   source_file date_start date_end   hcpcs mod   description          status_code
#>   <chr>       <date>     <date>     <chr> <chr> <chr>                <chr>      
#> 1 rvu24ar_jan 2024-01-01 2024-03-31 99213 NA    Office o/p est low … A          
#> # ℹ 27 more variables: not_used_for_medicare_payment <chr>, work_rvu <dbl>,
#> #   non_fac_pe_rvu <dbl>, non_fac_indicator <chr>, facility_pe_rvu <dbl>,
#> #   facility_indicator <chr>, mp_rvu <dbl>, non_facility_total <dbl>,
#> #   facility_total <dbl>, pctc_ind <chr>, glob_days <chr>, pre_op <dbl>,
#> #   intra_op <dbl>, post_op <dbl>, mult_proc <chr>, bilat_surg <chr>,
#> #   asst_surg <chr>, co_surg <chr>, team_surg <chr>, endo_base <chr>,
#> #   conv_factor <dbl>, physician_supervision_of_diagnostic_procedures <chr>, …
get_pprrvu(dos = "2024-02-28", hcpcs = "99213", pos = "Facility")
#> # A tibble: 1 × 34
#>   source_file date_start date_end   hcpcs mod   description          status_code
#>   <chr>       <date>     <date>     <chr> <chr> <chr>                <chr>      
#> 1 rvu24ar_jan 2024-01-01 2024-03-31 99213 NA    Office o/p est low … A          
#> # ℹ 27 more variables: not_used_for_medicare_payment <chr>, work_rvu <dbl>,
#> #   non_fac_pe_rvu <dbl>, non_fac_indicator <chr>, facility_pe_rvu <dbl>,
#> #   facility_indicator <chr>, mp_rvu <dbl>, non_facility_total <dbl>,
#> #   facility_total <dbl>, pctc_ind <chr>, glob_days <chr>, pre_op <dbl>,
#> #   intra_op <dbl>, post_op <dbl>, mult_proc <chr>, bilat_surg <chr>,
#> #   asst_surg <chr>, co_surg <chr>, team_surg <chr>, endo_base <chr>,
#> #   conv_factor <dbl>, physician_supervision_of_diagnostic_procedures <chr>, …
```
