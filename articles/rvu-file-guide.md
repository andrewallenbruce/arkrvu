# Customary Charge

To determine a physician’s customary charge for a particular procedure
where there is no reliable statistical basis, multiply the relative
value of the procedure by the physician’s customary charge conversion
factor for the appropriate category of service (e.g., radiology,
medicine, surgery).

## Customary Charge Formula

Compute a Customary Charge Conversion Factor for a physician with the
following charge history:

``` r
charges <- data.frame(
  procedure = 1:5,
  charge = c(5, 12, 35, 20, 8),
  value = c(1, 2, 4, 3, 1.5),
  frequency = c(3, 7, 5, 4, 6)
)

charges
```

    #>   procedure charge value frequency
    #> 1         1      5   1.0         3
    #> 2         2     12   2.0         7
    #> 3         3     35   4.0         5
    #> 4         4     20   3.0         4
    #> 5         5      8   1.5         6

For each procedure, divide the customary `charge` by the relative
`value`, then multiply the result by that procedure’s `frequency`:

``` r
charges <- collapse::mtt(charges, calculation = (charge / value) * frequency)
charges
```

    #>   procedure charge value frequency calculation
    #> 1         1      5   1.0         3    15.00000
    #> 2         2     12   2.0         7    42.00000
    #> 3         3     35   4.0         5    43.75000
    #> 4         4     20   3.0         4    26.66667
    #> 5         5      8   1.5         6    32.00000

Divide the sum of the `calculation` by the sum of the `frequency`:

``` r
sum(charges$calculation) / sum(charges$frequency)
```

    #> [1] 6.376667

------------------------------------------------------------------------

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
