# Validate HCPCS Codes

Validate HCPCS Codes

## Usage

``` r
is_hcpcs(hcpcs)

is_hcpcs_I(hcpcs)

is_hcpcs_II(hcpcs)

is_cpt_I(hcpcs)

is_cpt_II(hcpcs)

is_cpt_III(hcpcs)

hcpcs_type(hcpcs)

hcpcs_level(hcpcs)

cpt_category(hcpcs)

hcpcs_section(hcpcs)

cpt_section(hcpcs)

classify_hcpcs(df)
```

## Source

[AMA Category II
Codes](https://www.ama-assn.org/practice-management/cpt/category-ii-codes)

[AMA Category III
Codes](https://www.ama-assn.org/practice-management/cpt/category-iii-codes)

## Arguments

- hcpcs:

  `<chr>` vector of possible HCPCS codes

- df:

  `<data.frame>` containing a column named `hcpcs`

## Value

`<lgl>` `TRUE` if valid, otherwise `FALSE`

## HCPCS Codes

- 5 characters long

- Begin with one of `[A-CEGHJ-MP-V0-9]`

- Followed by any 3 digits, `[0-9]{3}`

- End with one of `[AFMTU0-9]`

## HCPCS Level I (CPT) Codes

- Begin with any 4 digits, `[0-9]{4}`

- End with one of `[AFMTU0-9]`

HCPCS Level I is comprised of CPT (Current Procedural Terminology), a
uniform numeric coding system maintained by the AMA, consisting of terms
and codes that are used to identify medical services and procedures
furnished by physicians and other health care professionals, to bill
public or private health insurance programs. Level I does not include
codes needed to separately report medical items or services that are
regularly billed by suppliers other than physicians.

## HCPCS Level II Codes

- Begin with one of `[A-CEGHJ-MP-V]`

- Ends with any 4 digits, `[0-9]{4}`

HCPCS Level II is a standardized coding system that is used primarily to
identify products, supplies, and services not included in the Level I
CPT codes, including ambulance services, durable medical equipment,
prosthetics, orthotics, and supplies (DMEPOS) when used outside a
physician's office.

Level II codes are also referred to as alpha-numeric codes because they
consist of a single alphabetical letter followed by 4 numeric digits,
while CPT codes are identified using 5 numeric digits.

## CPT Category I Codes

- Begins with any 4 digits, `[0-9]{4}`, and

- Ends with one of `[AMU0-9]`

## CPT Category II Codes

- Begins with any 4 digits, `[0-9]{4}`, and

- Ends with an `[F]`

Category II codes are supplemental tracking codes that are used to track
services on claims for performance measurement and are not billing
codes.

These codes are intended to facilitate data collection about quality of
care by coding certain services and/or test results that support
performance measures and that have been agreed upon as contributing to
good patient care.

Some codes in this category may relate to compliance by the health care
professional with state or federal law. The use of these codes is
optional. The codes are not required for correct coding and may not be
used as a substitute for Category I codes.

Services/procedures or test results described in this category make use
of alpha characters as the 5th character in the string (i.e., 4 digits
followed by an alpha character).

These digits are not intended to reflect the placement of the code in
the regular (Category I) part of the CPT code set.

Also, these codes describe components that are typically included in an
evaluation and management service or test results that are part of the
laboratory test/procedure. Consequently, they do not have a relative
value associated with them.

## CPT Category III Codes

- Begins with any 4 digits, `[0-9]{4}`, and

- Ends with a `[T]`

CPT Category III codes are a set of temporary codes that allow data
collection for emerging technologies and are used in the the Food and
Drug Administration (FDA) approval process.

No RVUs are assigned to these codes and payment is based on payer
policy. If a Category III code is available, it must be reported in
place of a Category I unlisted code.

The procedure/service they describe may not meet the following Category
I requirements:

- Necessary devices/drugs have received FDA clearance/approval.

- It is performed by many US physicians/QHPs, at a frequency consistent
  with intended clinical use.

- It is consistent with current medical practice.

- It's clinical efficacy is documented in CPT-approved literature.

## Examples

``` r
x <- c("T1503", "G0478", "81301", "69641", "0583F", "0779T", NA, "1164")
y <- c("39503", "99215", "99140", "70010", "0222U", "V5299", "7010F")

is_hcpcs(x)
#> [1]  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE
is_hcpcs_I(x)
#> [1] FALSE FALSE  TRUE  TRUE  TRUE  TRUE FALSE FALSE
is_hcpcs_II(x)
#> [1]  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE
is_cpt_I(x)
#> [1] FALSE FALSE  TRUE  TRUE FALSE FALSE FALSE FALSE
is_cpt_II(x)
#> [1] FALSE FALSE FALSE FALSE  TRUE FALSE FALSE FALSE
is_cpt_III(x)
#> [1] FALSE FALSE FALSE FALSE FALSE  TRUE FALSE FALSE

fastplyr::new_tbl(hcpcs = c(x, y)) |>
   classify_hcpcs()
#> # A tibble: 15 × 4
#>    hcpcs type  level    section                
#>  * <chr> <fct> <fct>    <fct>                  
#>  1 T1503 HCPCS HCPCS II Medicaid               
#>  2 G0478 HCPCS HCPCS II Professional           
#>  3 81301 CPT   CPT I    Pathology              
#>  4 69641 CPT   CPT I    Surgery                
#>  5 0583F CPT   CPT II   Performance Measurement
#>  6 0779T CPT   CPT III  New Technology         
#>  7 NA    NA    NA       NA                     
#>  8 1164  NA    NA       NA                     
#>  9 39503 CPT   CPT I    Surgery                
#> 10 99215 CPT   CPT I    E&M                    
#> 11 99140 CPT   CPT I    Anesthesiology         
#> 12 70010 CPT   CPT I    Radiology              
#> 13 0222U CPT   CPT I    Laboratory             
#> 14 V5299 HCPCS HCPCS II Vision-Hearing-Speech  
#> 15 7010F CPT   CPT II   Performance Measurement
```
