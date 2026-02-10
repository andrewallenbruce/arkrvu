# RVU Information Tables

RVU Information Tables

## Usage

``` r
rvu_link_table(years)

rvu_zip_links(years)

conversion_factor(dos)
```

## Arguments

- years:

  `<int>` RVU source file year

- dos:

  `<Date>` Date of Service, in the form YYYY-MM-DD

## Value

`<tibble>` containing RVU information

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
rvu_zip_links()
#> # A tibble: 77 × 6
#>     year file         date_start date_end   description                    url  
#>    <int> <chr>        <date>     <chr>      <chr>                          <chr>
#>  1  2009 RVU09A       2009-01-01 2009-03-31 Physician Fee Schedule - Janu… http…
#>  2  2009 RVU09AR      2009-01-01 2009-03-31 Physician Fee Schedule has be… http…
#>  3  2009 RVU09B       2009-04-01 2009-06-30 Physician Fee Schedule has be… http…
#>  4  2009 RVU09C       2009-07-01 2009-12-31 Physician Fee Schedule has be… http…
#>  5  2010 RVU10AR1     2010-01-01 2010-06-30 NOTE: This is a re-posting of… http…
#>  6  2010 RVU10C_PCT0  2010-07-01 2010-09-30 Physician Fee Schedule - July… http…
#>  7  2010 RVU10C_PCT22 2010-07-01 2010-09-30 Physician Fee Schedule - This… http…
#>  8  2010 RVU10D_PCT0  2010-10-01 2010-12-31 Physician Fee Schedule has be… http…
#>  9  2010 RVU10D_PCT22 2010-10-01 2010-12-31 Physician Fee Schedule has be… http…
#> 10  2011 RVU11A       2011-01-01 2010-12-31 Physician Fee Schedule - Janu… http…
#> # ℹ 67 more rows
conversion_factor("2023-03-03")
#> # A tibble: 1 × 6
#>   date_start date_end                    date_iv    cf chg_abs chg_rel
#>   <date>     <date>                   <iv<date>> <dbl>   <dbl>   <dbl>
#> 1 2023-01-01 2023-12-31 [2023-01-01, 2024-01-01)  33.9  -0.719 -0.0208
conversion_factor(make_date(2018:2025))
#> # A tibble: 7 × 6
#>   date_start date_end                    date_iv    cf chg_abs  chg_rel
#>   <date>     <date>                   <iv<date>> <dbl>   <dbl>    <dbl>
#> 1 2018-01-01 2018-12-31 [2018-01-01, 2019-01-01)  36.0  0.111   0.00309
#> 2 2019-01-01 2019-12-31 [2019-01-01, 2020-01-01)  36.0  0.0395  0.00110
#> 3 2020-01-01 2020-12-31 [2020-01-01, 2021-01-01)  36.1  0.0505  0.00140
#> 4 2021-01-01 2021-12-31 [2021-01-01, 2022-01-01)  34.9 -1.20   -0.0332 
#> 5 2022-01-01 2022-12-31 [2022-01-01, 2023-01-01)  34.6 -0.287  -0.00822
#> 6 2023-01-01 2023-12-31 [2023-01-01, 2024-01-01)  33.9 -0.719  -0.0208 
#> 7 2024-01-01 2024-03-08 [2024-01-01, 2024-03-09)  32.7 -1.14   -0.0337 
conversion_factor()
#> # A tibble: 36 × 6
#>    date_start date_end                    date_iv    cf chg_abs chg_rel
#>  * <date>     <date>                   <iv<date>> <dbl>   <dbl>   <dbl>
#>  1 1992-01-01 1992-12-31 [1992-01-01, 1993-01-01)  31.0   NA    NA     
#>  2 1993-01-01 1993-12-31 [1993-01-01, 1994-01-01)  31.0    0     0     
#>  3 1994-01-01 1994-12-31 [1994-01-01, 1995-01-01)  31.0    0     0     
#>  4 1995-01-01 1995-12-31 [1995-01-01, 1996-01-01)  31.0    0     0     
#>  5 1996-01-01 1996-12-31 [1996-01-01, 1997-01-01)  31.0    0     0     
#>  6 1997-01-01 1997-12-31 [1997-01-01, 1998-01-01)  31.0    0     0     
#>  7 1998-01-01 1998-12-31 [1998-01-01, 1999-01-01)  36.7    5.69  0.183 
#>  8 1999-01-01 1999-12-31 [1999-01-01, 2000-01-01)  34.7   -1.96 -0.0533
#>  9 2000-01-01 2000-12-31 [2000-01-01, 2001-01-01)  36.6    1.88  0.0542
#> 10 2001-01-01 2001-12-31 [2001-01-01, 2002-01-01)  38.3    1.64  0.0449
#> # ℹ 26 more rows
```
