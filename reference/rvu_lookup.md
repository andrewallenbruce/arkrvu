# RVU Lookup by Date of Service, HCPCS, and Place of Service

RVU Lookup by Date of Service, HCPCS, and Place of Service

## Usage

``` r
rvu_lookup(dos, hcpcs, pos, ...)
```

## Arguments

- dos:

  `<date>` date of service; YYYY-MM-DD

- hcpcs:

  `<chr>` HCPCS code or vector of HCPCS codes

- pos:

  `<chr>` Place of Service indicator; `Facility` or `Non-Facility`

- ...:

  additional arguments

## Value

`<tibble>` containing RVU values for specified parameters

## Examples

``` r
rvu_lookup(dos = "2024-03-31", hcpcs = "99215", pos = "Non-Facility")
#> # A tibble: 1 × 30
#>   source_file date_start date_end   hcpcs mod   description          status_code
#>   <chr>       <date>     <date>     <chr> <chr> <chr>                <chr>      
#> 1 rvu24ar_jan 2024-01-01 2024-03-31 99215 NA    Office o/p est hi 4… A          
#> # ℹ 23 more variables: not_used_for_medicare_payment <chr>, work_rvu <dbl>,
#> #   non_fac_pe_rvu <dbl>, non_fac_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, pctc_ind <chr>, glob_days <chr>, pre_op <dbl>,
#> #   intra_op <dbl>, post_op <dbl>, mult_proc <chr>, bilat_surg <chr>,
#> #   asst_surg <chr>, co_surg <chr>, team_surg <chr>, endo_base <chr>,
#> #   conv_factor <dbl>, physician_supervision_of_diagnostic_procedures <chr>,
#> #   calculation_flag <chr>, diagnostic_imaging_family_indicator <chr>, …
rvu_lookup(dos = "2024-02-28", hcpcs = "99215", pos = "Facility")
#> # A tibble: 1 × 30
#>   source_file date_start date_end   hcpcs mod   description          status_code
#>   <chr>       <date>     <date>     <chr> <chr> <chr>                <chr>      
#> 1 rvu24ar_jan 2024-01-01 2024-03-31 99215 NA    Office o/p est hi 4… A          
#> # ℹ 23 more variables: not_used_for_medicare_payment <chr>, work_rvu <dbl>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   facility_total <dbl>, pctc_ind <chr>, glob_days <chr>, pre_op <dbl>,
#> #   intra_op <dbl>, post_op <dbl>, mult_proc <chr>, bilat_surg <chr>,
#> #   asst_surg <chr>, co_surg <chr>, team_surg <chr>, endo_base <chr>,
#> #   conv_factor <dbl>, physician_supervision_of_diagnostic_procedures <chr>,
#> #   calculation_flag <chr>, diagnostic_imaging_family_indicator <chr>, …
```
