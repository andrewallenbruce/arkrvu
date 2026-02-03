# RVU Raw Source Files

RVU Raw Source Files

## Usage

``` r
raw_source(year, type)
```

## Arguments

- year:

  `<int>` year of RVU source file

- type:

  `<chr>` RVU source file type, one of:

  - `pprrvu`: PPRRVU

  - `oppscap`: OPPSCAP

  - `gpci`: GPCI

  - `locco`: LOCCO

  - `anes`: ANESTHESIA

## Value

`<list>` of tibbles containing RVU source files

## Examples

``` r
raw_source(year = 2024, type = "pprrvu")
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
raw_source(year = 2023, type = "gpci")
#> $rvu23a
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.878   0.748    0.875
#>  2 02102 AK    01              ALASKA              1.5    1.1     0.603    1.07 
#>  3 03102 AZ    00              ARIZONA             1      0.963   0.855    0.939
#>  4 07102 AR    13              ARKANSAS            1      0.853   0.492    0.782
#>  5 01112 CA    54              BAKERSFIELD         1.03   1.08    0.694    0.933
#>  6 01112 CA    55              CHICO               1.02   1.08    0.579    0.893
#>  7 01182 CA    71              EL CENTRO           1.02   1.08    0.595    0.898
#>  8 01112 CA    56              FRESNO              1.02   1.08    0.579    0.893
#>  9 01112 CA    57              HANFORD-CORCO…      1.02   1.08    0.579    0.893
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.18    0.724    0.985
#> # ℹ 102 more rows
#> 
#> $rvu23b
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.878   0.748    0.875
#>  2 02102 AK    01              ALASKA              1.5    1.1     0.603    1.07 
#>  3 03102 AZ    00              ARIZONA             1      0.963   0.855    0.939
#>  4 07102 AR    13              ARKANSAS            1      0.853   0.492    0.782
#>  5 01112 CA    54              BAKERSFIELD         1.03   1.08    0.694    0.933
#>  6 01112 CA    55              CHICO               1.02   1.08    0.579    0.893
#>  7 01182 CA    71              EL CENTRO           1.02   1.08    0.595    0.898
#>  8 01112 CA    56              FRESNO              1.02   1.08    0.579    0.893
#>  9 01112 CA    57              HANFORD-CORCO…      1.02   1.08    0.579    0.893
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.18    0.724    0.985
#> # ℹ 102 more rows
#> 
#> $rvu23c
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.878   0.748    0.875
#>  2 02102 AK    01              ALASKA              1.5    1.1     0.603    1.07 
#>  3 03102 AZ    00              ARIZONA             1      0.963   0.855    0.939
#>  4 07102 AR    13              ARKANSAS            1      0.853   0.492    0.782
#>  5 01112 CA    54              BAKERSFIELD         1.03   1.08    0.694    0.933
#>  6 01112 CA    55              CHICO               1.02   1.08    0.579    0.893
#>  7 01182 CA    71              EL CENTRO           1.02   1.08    0.595    0.898
#>  8 01112 CA    56              FRESNO              1.02   1.08    0.579    0.893
#>  9 01112 CA    57              HANFORD-CORCO…      1.02   1.08    0.579    0.893
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.18    0.724    0.985
#> # ℹ 102 more rows
#> 
#> $rvu23d
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.878   0.748    0.875
#>  2 02102 AK    01              ALASKA              1.5    1.1     0.603    1.07 
#>  3 03102 AZ    00              ARIZONA             1      0.963   0.855    0.939
#>  4 07102 AR    13              ARKANSAS            1      0.853   0.492    0.782
#>  5 01112 CA    54              BAKERSFIELD         1.03   1.08    0.694    0.933
#>  6 01112 CA    55              CHICO               1.02   1.08    0.579    0.893
#>  7 01182 CA    71              EL CENTRO           1.02   1.08    0.595    0.898
#>  8 01112 CA    56              FRESNO              1.02   1.08    0.579    0.893
#>  9 01112 CA    57              HANFORD-CORCO…      1.02   1.08    0.579    0.893
#> 10 01182 CA    18              LOS ANGELES-L…      1.04   1.18    0.724    0.985
#> # ℹ 102 more rows
#> 
raw_source(year = 2022)
#> Returning all RVU source files for year 2022.
#> $table
#> # A tibble: 4 × 5
#>   file_html date_effective last_updated zip_link                       sub_files
#>   <chr>     <date>         <date>       <chr>                          <list>   
#> 1 RVU22A    2022-01-01     NA           https://www.cms.gov/files/zip… <tibble> 
#> 2 RVU22B    2022-04-01     NA           https://www.cms.gov/files/zip… <tibble> 
#> 3 RVU22C    2022-07-01     2022-06-17   https://www.cms.gov/files/zip… <tibble> 
#> 4 RVU22D    2022-10-01     NA           https://www.cms.gov/files/zip… <tibble> 
#> 
#> $pprrvu
#> $pprrvu$rvu22a_jan
#> # A tibble: 17,600 × 31
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
#> # ℹ 17,590 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> $pprrvu$rvu22b_apr
#> # A tibble: 17,630 × 31
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
#> # ℹ 17,620 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> $pprrvu$rvu22c_jul
#> # A tibble: 17,695 × 31
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
#> # ℹ 17,685 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> $pprrvu$rvu22d_oct
#> # A tibble: 17,726 × 31
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
#> # ℹ 17,716 more rows
#> # ℹ abbreviated name: ¹​not_used_for_medicare_payment
#> # ℹ 25 more variables: non_fac_pe_rvu <dbl>, non_fac_indicator <chr>,
#> #   facility_pe_rvu <dbl>, facility_indicator <chr>, mp_rvu <dbl>,
#> #   non_facility_total <dbl>, facility_total <dbl>, pctc_ind <chr>,
#> #   glob_days <chr>, pre_op <dbl>, intra_op <dbl>, post_op <dbl>,
#> #   mult_proc <chr>, bilat_surg <chr>, asst_surg <chr>, co_surg <chr>, …
#> 
#> 
#> $oppscap
#> $oppscap$rvu22a_jan
#> # A tibble: 18,564 × 7
#>    hcpcs mod   procstat carrier locality facility_price non_facility_price
#>    <chr> <chr> <chr>    <chr>   <chr>             <dbl>              <dbl>
#>  1 0633T TC    C        01112   05                 147.               147.
#>  2 0633T TC    C        01112   06                 147.               147.
#>  3 0633T TC    C        01112   07                 147.               147.
#>  4 0633T TC    C        01112   09                 153.               153.
#>  5 0633T TC    C        01112   17                 131.               131.
#>  6 0633T TC    C        01112   18                 130.               130.
#>  7 0633T TC    C        01112   26                 130.               130.
#>  8 0633T TC    C        01112   51                 135.               135.
#>  9 0633T TC    C        01112   52                 147.               147.
#> 10 0633T TC    C        01112   53                 135.               135.
#> # ℹ 18,554 more rows
#> 
#> $oppscap$rvu22b_apr
#> # A tibble: 18,564 × 7
#>    hcpcs mod   procstat carrier locality facility_price non_facility_price
#>    <chr> <chr> <chr>    <chr>   <chr>             <dbl>              <dbl>
#>  1 0633T TC    C        01112   05                 147.               147.
#>  2 0633T TC    C        01112   06                 147.               147.
#>  3 0633T TC    C        01112   07                 147.               147.
#>  4 0633T TC    C        01112   09                 153.               153.
#>  5 0633T TC    C        01112   17                 131.               131.
#>  6 0633T TC    C        01112   18                 130.               130.
#>  7 0633T TC    C        01112   26                 130.               130.
#>  8 0633T TC    C        01112   51                 135.               135.
#>  9 0633T TC    C        01112   52                 147.               147.
#> 10 0633T TC    C        01112   53                 135.               135.
#> # ℹ 18,554 more rows
#> 
#> $oppscap$rvu22c_jul
#> # A tibble: 18,564 × 7
#>    hcpcs mod   procstat carrier locality facility_price non_facility_price
#>    <chr> <chr> <chr>    <chr>   <chr>             <dbl>              <dbl>
#>  1 0633T TC    C        01112   05                 147.               147.
#>  2 0633T TC    C        01112   06                 147.               147.
#>  3 0633T TC    C        01112   07                 147.               147.
#>  4 0633T TC    C        01112   09                 153.               153.
#>  5 0633T TC    C        01112   17                 131.               131.
#>  6 0633T TC    C        01112   18                 130.               130.
#>  7 0633T TC    C        01112   26                 130.               130.
#>  8 0633T TC    C        01112   51                 135.               135.
#>  9 0633T TC    C        01112   52                 147.               147.
#> 10 0633T TC    C        01112   53                 135.               135.
#> # ℹ 18,554 more rows
#> 
#> $oppscap$rvu22d_oct
#> # A tibble: 18,564 × 7
#>    hcpcs mod   procstat carrier locality facility_price non_facility_price
#>    <chr> <chr> <chr>    <chr>   <chr>             <dbl>              <dbl>
#>  1 0633T TC    C        01112   05                 147.               147.
#>  2 0633T TC    C        01112   06                 147.               147.
#>  3 0633T TC    C        01112   07                 147.               147.
#>  4 0633T TC    C        01112   09                 153.               153.
#>  5 0633T TC    C        01112   17                 131.               131.
#>  6 0633T TC    C        01112   18                 130.               130.
#>  7 0633T TC    C        01112   26                 130.               130.
#>  8 0633T TC    C        01112   51                 135.               135.
#>  9 0633T TC    C        01112   52                 147.               147.
#> 10 0633T TC    C        01112   53                 135.               135.
#> # ℹ 18,554 more rows
#> 
#> 
#> $gpci
#> $gpci$rvu22a
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.888   0.921    0.936
#>  2 02102 AK    01              ALASKA              1.5    1.12    0.614    1.08 
#>  3 03102 AZ    00              ARIZONA             1      0.951   0.857    0.936
#>  4 07102 AR    13              ARKANSAS            1      0.847   0.465    0.771
#>  5 01112 CA    54              BAKERSFIELD         1.04   1.06    0.726    0.942
#>  6 01112 CA    55              CHICO               1.03   1.06    0.597    0.896
#>  7 01182 CA    71              EL CENTRO           1.03   1.06    0.62     0.904
#>  8 01112 CA    56              FRESNO              1.03   1.06    0.597    0.896
#>  9 01112 CA    57              HANFORD-CORCO…      1.03   1.06    0.597    0.896
#> 10 01182 CA    18              LOS ANGELES-L…      1.05   1.18    0.757    0.993
#> # ℹ 102 more rows
#> 
#> $gpci$rvu22b
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.888   0.921    0.936
#>  2 02102 AK    01              ALASKA              1.5    1.12    0.614    1.08 
#>  3 03102 AZ    00              ARIZONA             1      0.951   0.857    0.936
#>  4 07102 AR    13              ARKANSAS            1      0.847   0.465    0.771
#>  5 01112 CA    54              BAKERSFIELD         1.04   1.06    0.726    0.942
#>  6 01112 CA    55              CHICO               1.03   1.06    0.597    0.896
#>  7 01182 CA    71              EL CENTRO           1.03   1.06    0.62     0.904
#>  8 01112 CA    56              FRESNO              1.03   1.06    0.597    0.896
#>  9 01112 CA    57              HANFORD-CORCO…      1.03   1.06    0.597    0.896
#> 10 01182 CA    18              LOS ANGELES-L…      1.05   1.18    0.757    0.993
#> # ℹ 102 more rows
#> 
#> $gpci$rvu22c
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.888   0.921    0.936
#>  2 02102 AK    01              ALASKA              1.5    1.12    0.614    1.08 
#>  3 03102 AZ    00              ARIZONA             1      0.951   0.857    0.936
#>  4 07102 AR    13              ARKANSAS            1      0.847   0.465    0.771
#>  5 01112 CA    54              BAKERSFIELD         1.04   1.06    0.726    0.942
#>  6 01112 CA    55              CHICO               1.03   1.06    0.597    0.896
#>  7 01182 CA    71              EL CENTRO           1.03   1.06    0.62     0.904
#>  8 01112 CA    56              FRESNO              1.03   1.06    0.597    0.896
#>  9 01112 CA    57              HANFORD-CORCO…      1.03   1.06    0.597    0.896
#> 10 01182 CA    18              LOS ANGELES-L…      1.05   1.18    0.757    0.993
#> # ℹ 102 more rows
#> 
#> $gpci$rvu22d
#> # A tibble: 112 × 8
#>    mac   state locality_number locality_name  gpci_work gpci_pe gpci_mp gpci_gaf
#>    <chr> <chr> <chr>           <chr>              <dbl>   <dbl>   <dbl>    <dbl>
#>  1 10112 AL    00              ALABAMA             1      0.888   0.921    0.936
#>  2 02102 AK    01              ALASKA              1.5    1.12    0.614    1.08 
#>  3 03102 AZ    00              ARIZONA             1      0.951   0.857    0.936
#>  4 07102 AR    13              ARKANSAS            1      0.847   0.465    0.771
#>  5 01112 CA    54              BAKERSFIELD         1.04   1.06    0.726    0.942
#>  6 01112 CA    55              CHICO               1.03   1.06    0.597    0.896
#>  7 01182 CA    71              EL CENTRO           1.03   1.06    0.62     0.904
#>  8 01112 CA    56              FRESNO              1.03   1.06    0.597    0.896
#>  9 01112 CA    57              HANFORD-CORCO…      1.03   1.06    0.597    0.896
#> 10 01182 CA    18              LOS ANGELES-L…      1.05   1.18    0.757    0.993
#> # ℹ 102 more rows
#> 
#> 
#> $locco
#> $locco$rvu22a
#> # A tibble: 114 × 6
#>    mac   locality_number state      fee_schedule_area         counties state_abb
#>    <chr> <chr>           <chr>      <chr>                     <chr>    <chr>    
#>  1 10112 00              ALABAMA    STATEWIDE                 ALL COU… AL       
#>  2 02102 01              ALASKA     STATEWIDE                 ALL COU… AK       
#>  3 03102 00              ARIZONA    STATEWIDE                 ALL COU… AZ       
#>  4 07102 13              ARKANSAS   STATEWIDE                 ALL COU… AR       
#>  5 01182 26              CALIFORNIA LOS ANGELES-LONG BEACH-A… ORANGE   CA       
#>  6 01182 18              CALIFORNIA LOS ANGELES-LONG BEACH-A… LOS ANG… CA       
#>  7 01112 52              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… MARIN    CA       
#>  8 01112 07              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… ALAMEDA… CA       
#>  9 01112 05              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN FRA… CA       
#> 10 01112 06              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN MAT… CA       
#> # ℹ 104 more rows
#> 
#> $locco$rvu22b
#> # A tibble: 114 × 6
#>    mac   locality_number state      fee_schedule_area         counties state_abb
#>    <chr> <chr>           <chr>      <chr>                     <chr>    <chr>    
#>  1 10112 00              ALABAMA    STATEWIDE                 ALL COU… AL       
#>  2 02102 01              ALASKA     STATEWIDE                 ALL COU… AK       
#>  3 03102 00              ARIZONA    STATEWIDE                 ALL COU… AZ       
#>  4 07102 13              ARKANSAS   STATEWIDE                 ALL COU… AR       
#>  5 01182 26              CALIFORNIA LOS ANGELES-LONG BEACH-A… ORANGE   CA       
#>  6 01182 18              CALIFORNIA LOS ANGELES-LONG BEACH-A… LOS ANG… CA       
#>  7 01112 52              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… MARIN    CA       
#>  8 01112 07              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… ALAMEDA… CA       
#>  9 01112 05              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN FRA… CA       
#> 10 01112 06              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN MAT… CA       
#> # ℹ 104 more rows
#> 
#> $locco$rvu22c
#> # A tibble: 114 × 6
#>    mac   locality_number state      fee_schedule_area         counties state_abb
#>    <chr> <chr>           <chr>      <chr>                     <chr>    <chr>    
#>  1 10112 00              ALABAMA    STATEWIDE                 ALL COU… AL       
#>  2 02102 01              ALASKA     STATEWIDE                 ALL COU… AK       
#>  3 03102 00              ARIZONA    STATEWIDE                 ALL COU… AZ       
#>  4 07102 13              ARKANSAS   STATEWIDE                 ALL COU… AR       
#>  5 01182 26              CALIFORNIA LOS ANGELES-LONG BEACH-A… ORANGE   CA       
#>  6 01182 18              CALIFORNIA LOS ANGELES-LONG BEACH-A… LOS ANG… CA       
#>  7 01112 52              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… MARIN    CA       
#>  8 01112 07              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… ALAMEDA… CA       
#>  9 01112 05              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN FRA… CA       
#> 10 01112 06              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN MAT… CA       
#> # ℹ 104 more rows
#> 
#> $locco$rvu22d
#> # A tibble: 114 × 6
#>    mac   locality_number state      fee_schedule_area         counties state_abb
#>    <chr> <chr>           <chr>      <chr>                     <chr>    <chr>    
#>  1 10112 00              ALABAMA    STATEWIDE                 ALL COU… AL       
#>  2 02102 01              ALASKA     STATEWIDE                 ALL COU… AK       
#>  3 03102 00              ARIZONA    STATEWIDE                 ALL COU… AZ       
#>  4 07102 13              ARKANSAS   STATEWIDE                 ALL COU… AR       
#>  5 01182 26              CALIFORNIA LOS ANGELES-LONG BEACH-A… ORANGE   CA       
#>  6 01182 18              CALIFORNIA LOS ANGELES-LONG BEACH-A… LOS ANG… CA       
#>  7 01112 52              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… MARIN    CA       
#>  8 01112 07              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… ALAMEDA… CA       
#>  9 01112 05              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN FRA… CA       
#> 10 01112 06              CALIFORNIA SAN FRANCISCO-OAKLAND-BE… SAN MAT… CA       
#> # ℹ 104 more rows
#> 
#> 
#> $anes
#> $anes$rvu22a
#> # A tibble: 113 × 4
#>    contractor locality locality_name                      anesthesia_conv_factor
#>    <chr>      <chr>    <chr>                                               <dbl>
#>  1 10112      00       ALABAMA                                              21.1
#>  2 02102      01       ALASKA                                               29.8
#>  3 03102      00       ARIZONA                                              21.2
#>  4 07102      13       ARKANSAS                                             20.3
#>  5 01112      54       BAKERSFIELD                                          22.0
#>  6 01112      55       CHICO                                                21.7
#>  7 01182      71       EL CENTRO                                            21.7
#>  8 01112      56       FRESNO                                               21.7
#>  9 01112      57       HANFORD-CORCORAN                                     21.7
#> 10 01182      18       LOS ANGELES-LONG BEACH-ANAHEIM (L…                   22.6
#> # ℹ 103 more rows
#> 
#> $anes$rvu22b
#> # A tibble: 113 × 4
#>    contractor locality locality_name                      anesthesia_conv_factor
#>    <chr>      <chr>    <chr>                                               <dbl>
#>  1 10112      00       ALABAMA                                              21.1
#>  2 02102      01       ALASKA                                               29.8
#>  3 03102      00       ARIZONA                                              21.2
#>  4 07102      13       ARKANSAS                                             20.3
#>  5 01112      54       BAKERSFIELD                                          22.0
#>  6 01112      55       CHICO                                                21.7
#>  7 01182      71       EL CENTRO                                            21.7
#>  8 01112      56       FRESNO                                               21.7
#>  9 01112      57       HANFORD-CORCORAN                                     21.7
#> 10 01182      18       LOS ANGELES-LONG BEACH-ANAHEIM (L…                   22.6
#> # ℹ 103 more rows
#> 
#> $anes$rvu22c
#> # A tibble: 113 × 4
#>    contractor locality locality_name                      anesthesia_conv_factor
#>    <chr>      <chr>    <chr>                                               <dbl>
#>  1 10112      00       ALABAMA                                              21.1
#>  2 02102      01       ALASKA                                               29.8
#>  3 03102      00       ARIZONA                                              21.2
#>  4 07102      13       ARKANSAS                                             20.3
#>  5 01112      54       BAKERSFIELD                                          22.0
#>  6 01112      55       CHICO                                                21.7
#>  7 01182      71       EL CENTRO                                            21.7
#>  8 01112      56       FRESNO                                               21.7
#>  9 01112      57       HANFORD-CORCORAN                                     21.7
#> 10 01182      18       LOS ANGELES-LONG BEACH-ANAHEIM (L…                   22.6
#> # ℹ 103 more rows
#> 
#> $anes$rvu22d
#> # A tibble: 113 × 4
#>    contractor locality locality_name                      anesthesia_conv_factor
#>    <chr>      <chr>    <chr>                                               <dbl>
#>  1 10112      00       ALABAMA                                              21.1
#>  2 02102      01       ALASKA                                               29.8
#>  3 03102      00       ARIZONA                                              21.2
#>  4 07102      13       ARKANSAS                                             20.3
#>  5 01112      54       BAKERSFIELD                                          22.0
#>  6 01112      55       CHICO                                                21.7
#>  7 01182      71       EL CENTRO                                            21.7
#>  8 01112      56       FRESNO                                               21.7
#>  9 01112      57       HANFORD-CORCORAN                                     21.7
#> 10 01182      18       LOS ANGELES-LONG BEACH-ANAHEIM (L…                   22.6
#> # ℹ 103 more rows
#> 
#> 
```
