# RVU Source File

RVU Source File

## Usage

``` r
get_source(year, source)
```

## Arguments

- year:

  `<int>` year of rvu source file; default is `2020`

- source:

  `<chr>` rvu source file (`pprvu`, `oppscap`, `gpci`, `locco`, `anes`)

## Value

`<list>` of tibbles containing rvu source files

## Examples

``` r
get_source(2024, "pprrvu")
#> $rvu24a_jan
#> # A tibble: 18,499 × 31
#>    hcpcs mod   description           status_code not_used_for_medicar…¹ work_rvu
#>    <chr> <chr> <chr>                 <chr>       <chr>                     <dbl>
#>  1 A0021 NA    Outside state ambula… I           NA                            0
#>  2 A0080 NA    Noninterest escort i… I           NA                            0
#>  3 A0090 NA    Interest escort in n… I           NA                            0
#>  4 A0100 NA    Nonemergency transpo… I           NA                            0
#>  5 A0110 NA    Nonemergency transpo… I           NA                            0
#>  6 A0120 NA    Noner transport mini… I           NA                            0
#>  7 A0130 NA    Noner transport whee… I           NA                            0
#>  8 A0140 NA    Nonemergency transpo… I           NA                            0
#>  9 A0160 NA    Noner transport case… I           NA                            0
#> 10 A0170 NA    Transport parking fe… I           NA                            0
#> # ℹ 18,489 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> $rvu24ar_jan
#> # A tibble: 18,499 × 31
#>    hcpcs mod   description           status_code not_used_for_medicar…¹ work_rvu
#>    <chr> <chr> <chr>                 <chr>       <chr>                     <dbl>
#>  1 A0021 NA    Outside state ambula… I           NA                            0
#>  2 A0080 NA    Noninterest escort i… I           NA                            0
#>  3 A0090 NA    Interest escort in n… I           NA                            0
#>  4 A0100 NA    Nonemergency transpo… I           NA                            0
#>  5 A0110 NA    Nonemergency transpo… I           NA                            0
#>  6 A0120 NA    Noner transport mini… I           NA                            0
#>  7 A0130 NA    Noner transport whee… I           NA                            0
#>  8 A0140 NA    Nonemergency transpo… I           NA                            0
#>  9 A0160 NA    Noner transport case… I           NA                            0
#> 10 A0170 NA    Transport parking fe… I           NA                            0
#> # ℹ 18,489 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> $rvu24b_apr
#> # A tibble: 18,534 × 31
#>    hcpcs mod   description           status_code not_used_for_medicar…¹ work_rvu
#>    <chr> <chr> <chr>                 <chr>       <chr>                     <dbl>
#>  1 A0021 NA    Outside state ambula… I           NA                            0
#>  2 A0080 NA    Noninterest escort i… I           NA                            0
#>  3 A0090 NA    Interest escort in n… I           NA                            0
#>  4 A0100 NA    Nonemergency transpo… I           NA                            0
#>  5 A0110 NA    Nonemergency transpo… I           NA                            0
#>  6 A0120 NA    Noner transport mini… I           NA                            0
#>  7 A0130 NA    Noner transport whee… I           NA                            0
#>  8 A0140 NA    Nonemergency transpo… I           NA                            0
#>  9 A0160 NA    Noner transport case… I           NA                            0
#> 10 A0170 NA    Transport parking fe… I           NA                            0
#> # ℹ 18,524 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> $rvu24c_jul
#> # A tibble: 18,664 × 31
#>    hcpcs mod   description           status_code not_used_for_medicar…¹ work_rvu
#>    <chr> <chr> <chr>                 <chr>       <chr>                     <dbl>
#>  1 A0021 NA    Outside state ambula… I           NA                            0
#>  2 A0080 NA    Noninterest escort i… I           NA                            0
#>  3 A0090 NA    Interest escort in n… I           NA                            0
#>  4 A0100 NA    Nonemergency transpo… I           NA                            0
#>  5 A0110 NA    Nonemergency transpo… I           NA                            0
#>  6 A0120 NA    Noner transport mini… I           NA                            0
#>  7 A0130 NA    Noner transport whee… I           NA                            0
#>  8 A0140 NA    Nonemergency transpo… I           NA                            0
#>  9 A0160 NA    Noner transport case… I           NA                            0
#> 10 A0170 NA    Transport parking fe… I           NA                            0
#> # ℹ 18,654 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
get_source(2024, "gpci")
#> $rvu24a
#> # A tibble: 109 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.869   0.575    0.815
#>  2 02102 AK    01              ALASKA              1.5    1.08    0.592    1.06 
#>  3 03102 AZ    00              ARIZONA             1      0.975   0.854    0.943
#>  4 07102 AR    13              ARKANSAS            1      0.86    0.518    0.793
#>  5 01112 CA    54              BAKERSFIELD         1.02   1.09    0.662    0.924
#>  6 01112 CA    55              CHICO               1.01   1.09    0.56     0.889
#>  7 01182 CA    71              EL CENTRO           1.01   1.09    0.57     0.892
#>  8 01112 CA    56              FRESNO              1.01   1.09    0.56     0.889
#>  9 01112 CA    57              HANFORD-CORCO…      1.01   1.09    0.56     0.889
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.19    0.69     0.975
#> # ℹ 99 more rows
#> 
#> $rvu24ar
#> # A tibble: 109 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.869   0.575    0.815
#>  2 02102 AK    01              ALASKA              1.5    1.08    0.592    1.06 
#>  3 03102 AZ    00              ARIZONA             1      0.975   0.854    0.943
#>  4 07102 AR    13              ARKANSAS            1      0.86    0.518    0.793
#>  5 01112 CA    54              BAKERSFIELD         1.02   1.09    0.662    0.924
#>  6 01112 CA    55              CHICO               1.01   1.09    0.56     0.889
#>  7 01182 CA    71              EL CENTRO           1.01   1.09    0.57     0.892
#>  8 01112 CA    56              FRESNO              1.01   1.09    0.56     0.889
#>  9 01112 CA    57              HANFORD-CORCO…      1.01   1.09    0.56     0.889
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.19    0.69     0.975
#> # ℹ 99 more rows
#> 
#> $rvu24b
#> # A tibble: 109 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.869   0.575    0.815
#>  2 02102 AK    01              ALASKA              1.5    1.08    0.592    1.06 
#>  3 03102 AZ    00              ARIZONA             1      0.975   0.854    0.943
#>  4 07102 AR    13              ARKANSAS            1      0.86    0.518    0.793
#>  5 01112 CA    54              BAKERSFIELD         1.02   1.09    0.662    0.924
#>  6 01112 CA    55              CHICO               1.01   1.09    0.56     0.889
#>  7 01182 CA    71              EL CENTRO           1.01   1.09    0.57     0.892
#>  8 01112 CA    56              FRESNO              1.01   1.09    0.56     0.889
#>  9 01112 CA    57              HANFORD-CORCO…      1.01   1.09    0.56     0.889
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.19    0.69     0.975
#> # ℹ 99 more rows
#> 
#> $rvu24c
#> # A tibble: 109 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.869   0.575    0.815
#>  2 02102 AK    01              ALASKA              1.5    1.08    0.592    1.06 
#>  3 03102 AZ    00              ARIZONA             1      0.975   0.854    0.943
#>  4 07102 AR    13              ARKANSAS            1      0.86    0.518    0.793
#>  5 01112 CA    54              BAKERSFIELD         1.02   1.09    0.662    0.924
#>  6 01112 CA    55              CHICO               1.01   1.09    0.56     0.889
#>  7 01182 CA    71              EL CENTRO           1.01   1.09    0.57     0.892
#>  8 01112 CA    56              FRESNO              1.01   1.09    0.56     0.889
#>  9 01112 CA    57              HANFORD-CORCO…      1.01   1.09    0.56     0.889
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.19    0.69     0.975
#> # ℹ 99 more rows
#> 
```
