# Validate HCPCS Codes

Validate HCPCS Codes

## Usage

``` r
is_hcpcs(hcpcs)

is_hcpcs_level_I(hcpcs)

is_hcpcs_level_II(hcpcs)

is_cpt_category_I(hcpcs)

is_cpt_category_II(hcpcs)

is_cpt_category_III(hcpcs)

hcpcs_category(hcpcs)

cpt_category(hcpcs)

hcpcs_level(hcpcs)

cpt_level(hcpcs)
```

## Source

[AMA Category II
Codes](https://www.ama-assn.org/practice-management/cpt/category-ii-codes)

[AMA Category III
Codes](https://www.ama-assn.org/practice-management/cpt/category-iii-codes)

## Arguments

- hcpcs:

  `<chr>` vector of possible HCPCS codes

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
x <- c("T1503", "G0478", "81301", "69641", "0583F", "0779T", NA)

is_hcpcs(x)
#> [1]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE

x[which(is_hcpcs(x))]
#> [1] "T1503" "G0478" "81301" "69641" "0583F" "0779T"

try(is_hcpcs("1164"))
#> Error in is_hcpcs("1164") : `hcpcs` must be 5 characters long.

is_hcpcs_level_I(x)
#> [1] FALSE FALSE  TRUE  TRUE  TRUE  TRUE FALSE
is_hcpcs_level_II(x)
#> [1]  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
is_cpt_category_I(x)
#> [1] FALSE FALSE  TRUE  TRUE FALSE FALSE FALSE
is_cpt_category_II(x)
#> [1] FALSE FALSE FALSE FALSE  TRUE FALSE FALSE
is_cpt_category_III(x)
#> [1] FALSE FALSE FALSE FALSE FALSE  TRUE FALSE

fastplyr::new_tbl(
   x = c("39503", "99215", "99140", "69990", "70010",
         "0222U", "V5299", "7010F", "0074T"),
   level = hcpcs_level(x)) |>
collapse::mtt(
    level = cheapr::if_else_(level == "CPT", cpt_level(x), level),
    category = cheapr::if_else_(level != "HCPCS II", cpt_category(x), hcpcs_category(x)))
#> # A tibble: 9 × 3
#>   x     level    category               
#>   <chr> <chr>    <chr>                  
#> 1 39503 CPT I    Surgery                
#> 2 99215 CPT I    E&M                    
#> 3 99140 CPT I    Anesthesiology         
#> 4 69990 CPT I    Surgery                
#> 5 70010 CPT I    Radiology              
#> 6 0222U CPT I    Path/Lab               
#> 7 V5299 HCPCS II Vision/Hearing         
#> 8 7010F CPT II   Performance Measurement
#> 9 0074T CPT III  New Technology         
```
