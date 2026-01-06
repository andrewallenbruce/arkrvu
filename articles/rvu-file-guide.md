# rvu-file-guide

## Customary Charge Formula

Use the following formula for the calculation of a customary charge
conversion factor:

\$\$

CF = \\ CHG = \\ SVC = \\ 1-n = \\ RVU = \\

\$\$

  

\$\$

CF =

\$\$

Compute a Customary Charge Conversion Factor for a physician with the
following charge history:

``` r
ex <- dplyr::tibble(
  Procedure = 1:5,
  `Customary Charge` = c(5, 12, 35, 20, 8),
  `Relative Value` = c(1, 2, 4, 3, 1.5),
  Frequency = c(3, 7, 5, 4, 6),
)

ex |> 
  gt::gt() |> 
  gt::opt_table_font(gt::google_font(name = "Fira Code")) |> 
  gt::tab_header(title = "Physician Charge History")
```

| Physician Charge History |                  |                |           |
|--------------------------|------------------|----------------|-----------|
| Procedure                | Customary Charge | Relative Value | Frequency |
| 1                        | 5                | 1.0            | 3         |
| 2                        | 12               | 2.0            | 7         |
| 3                        | 35               | 4.0            | 5         |
| 4                        | 20               | 3.0            | 4         |
| 5                        | 8                | 1.5            | 6         |

  

Method:

1.  For each procedure, divide the customary charge by the relative
    value and multiply the result by the frequency of that procedure in
    the physician’s charge history.
2.  Add all the results of these computations.
3.  Divide the result by the sum of all the frequencies.

``` r
ex <- ex |> 
  dplyr::mutate(step = (`Customary Charge` / `Relative Value`) * Frequency)
  
ex |> 
  gt::gt() |> 
  gt::opt_table_font(gt::google_font(name = "Fira Code")) |> 
  gt::tab_header(title = "Physician Charge History")
```

| Physician Charge History |                  |                |           |          |
|--------------------------|------------------|----------------|-----------|----------|
| Procedure                | Customary Charge | Relative Value | Frequency | step     |
| 1                        | 5                | 1.0            | 3         | 15.00000 |
| 2                        | 12               | 2.0            | 7         | 42.00000 |
| 3                        | 35               | 4.0            | 5         | 43.75000 |
| 4                        | 20               | 3.0            | 4         | 26.66667 |
| 5                        | 8                | 1.5            | 6         | 32.00000 |

``` r
ex |> 
  dplyr::summarise(`Conversion Factor` = sum(step) / sum(Frequency)) |> 
  gt::gt() |> 
  gt::opt_table_font(gt::google_font(name = "Fira Code")) |> 
  gt::tab_header(title = "Physician Charge History")
```

| Physician Charge History |
|--------------------------|
| Conversion Factor        |
| 6.376667                 |

  

To determine a physician’s customary charge for a particular procedure
where there is no reliable statistical basis, multiply the relative
value of the procedure by the physician’s customary charge conversion
factor for the appropriate category of service (e.g., radiology,
medicine, surgery).

## Prevailing Charges

The prevailing charge conversion factors used with the appropriate
relative value scale are developed from the same formula used for
customary charge conversion factors, except that:

- **CHG**: The fully adjusted locality prevailing charge for a procedure
  by locality and by specialty or group of specialties (regardless of
  the source of data from which the locality prevailing charge was
  developed).
- **SVC**: The number of times the procedure was performed by all
  physicians in the same specialty or group of specialties and locality.
- **1-n**: The different procedures within a category of service for
  which prevailing charges have been established by specialty or group
  of specialties and locality.

The conversion factors calculated for any fee screen year reflect
customary and prevailing charges calculated on the basis of charge data
for the year ending June 30 immediately preceding the start of the fee
screen year.

Also, reasonable charge screens established through the use of a
relative value scale and conversion factors consist of two components.

Consequently, the conversion factors must be recalculated when there is
any change in the relative value units assigned to procedures (as may
occur if you use a different or updated relative value scale) in order
to assure that the change(s) in unit values do not violate the integrity
of the reasonable charge screens.

The economic index limitation, the no rollback provision, and the
Administrative Savings Clause are not applied directly to prevailing
charge conversion factors calculated in accordance with this section.
