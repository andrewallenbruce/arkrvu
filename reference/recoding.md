# Recoding Indicators

Recoding Indicators

## Usage

``` r
recode_glob(x)

recode_team(x)

recode_bilat(x)

recode_mult(x)

recode_cosurg(x)

recode_asst(x)

recode_diag(x)

recode_pctc(x)

recode_status(x, which = c("name", "description"))

recode_podp(x)
```

## Arguments

- x:

  `<chr>` vector of indicators

- which:

  `<chr>` name of recoding to perform; one of `"name"` or
  `"description"`

## Value

`<chr>` vector of descriptions

## Multiple Surgery

100% of MPFS amount is allowed for highest valued surgical procedure and
50% for additional surgical procedures (with a multiple surgery
indicator of "2") performed same day. Modifier 51 will be appended to
identify reduced services.

## Assistant Surgery

Fee schedule amount equals 16% of amount otherwise applicable for
surgical payment.

Modifiers:

- 80: Assistance by Another Physician

- 81: Minimal Assistance by a Another Physician

- 82: Assistance by Another Physician when Qualified Resident Surgeon
  Unavailable

- AS: Non-Physician Assistant at Surgery

Physician Assistant-at-surgery Services:

- Allowed at 85% of MPFS and then 16% of that amount is allowed for
  Assistant-at-surgery.

## Diagnostic Imaging

Identifies the applicable Diagnostic Service family for HCPCS codes with
a Multiple Procedure indicator of `4`.

## Examples

``` r
# Global Days
recode_glob(c("000", "010", "090", "MMM", "XXX", "YYY", "ZZZ"))
#> [1] "Endoscopic or minor procedure with related Preoperative and Postoperative RVUs on the day of the procedure only included in the fee schedule payment amount. E&M services on the day of the procedure generally not payable."                                                  
#> [2] "Minor procedure with Preoperative RVUs on the day of the procedure and Postoperative RVUs during a 10-day postoperative period included in the fee schedule amount. E&M services on the day of the procedure and during the 10-day postoperative period generally not payable."
#> [3] "Major surgery with a 1-day Preoperative period and 90-day Postoperative period included in fee schedule amount."                                                                                                                                                               
#> [4] "Maternity codes. Usual Global period does not apply."                                                                                                                                                                                                                          
#> [5] "Global concept does not apply."                                                                                                                                                                                                                                                
#> [6] "Carrier determines if Global concept applies and, if appropriate, establishes Postoperative period."                                                                                                                                                                           
#> [7] "Code related to another service and is always included in Global period of other service."                                                                                                                                                                                     

# Team Surgery (Mod 66)
recode_team(c(0:2, "9"))
#> [1] "Not Permitted"                           
#> [2] "Medical Necessity Documentation Required"
#> [3] "Permitted"                               
#> [4] "Concept does not apply"                  

# Bilateral Surgery (Mod 50)
recode_bilat(c(0:3, "9"))
#> [1] "Adjustment does not apply. If reported with mod 50 or RT and LT, payment for the two sides is the lower of (a) total charge for both sides (b) 100% of fee schedule amount for a single code. Adjustment is inappropriate because (a) of physiology or anatomy, or (b) code description states it is a unilateral procedure and there is an existing code for the bilateral procedure."                                                                                                                                                                                                                               
#> [2] "Adjustment applies. If reported with bilateral modifier or twice on same day by any other means (with RT and LT mods, or with a 2 in the units field), base payment on lower of: (a) total charge for both sides or (b) 150% of fee schedule amount for a single code. If reported as bilateral procedure and reported with other procedure codes on same day, apply bilateral adjustment before applying any multiple procedure rules."                                                                                                                                                                              
#> [3] "Adjustment does not apply. RVUs already based on procedure as a bilateral procedure. If reported with mod -50 or twice on same day by any other means, base payment on lower of (a) total charge for both sides, or (b) 100% of fee schedule for a single code."                                                                                                                                                                                                                                                                                                                                                      
#> [4] "Adjustment does not apply. If reported with mod 50 or for both sides on same day by any other means, base payment for each side or organ or site of paired organ on lower of (a) charge for each side or (b) 100% of fee schedule amount for each side. If reported as bilateral procedure and with other procedure codes on same day, determine fee schedule amount for a bilateral procedure before applying any multiple procedure rules. Services in this category are generally radiology procedures or other diagnostic tests which are not subject to the special payment rules for other bilateral surgeries."
#> [5] "Concept does not apply"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               

# Multiple Procedure (Mod 51)
recode_mult(as.character(0:9))
#>  [1] "No adjustment. If procedure is reported on the same day as another procedure, base the payment on the lower of (a) the actual charge, or (b) the fee schedule amount for the procedure."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
#>  [2] "Standard adjustment. If reported on the same day as another procedure with an indicator of 1, 2, or 3, rank the procedures by fee schedule amount and apply the appropriate reduction to this code (100%, 50%, 25%, 25%, 25%, and by report). Base payment on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
#>  [3] "Standard adjustment. If reported on the same day as another procedure with an indicator of 1, 2, or 3, rank the procedures by fee schedule amount and apply the appropriate reduction to this code (100%, 50%, 50%, 50%, 50% and by report). Base payment on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#>  [4] "Special rules for multiple endoscopic procedures apply if procedure is billed with another endoscopy in the same family (i.e., another endoscopy that has the same base procedure). The base procedure for each code with this indicator is identified in the Endobase column. Apply the multiple endoscopy rules to a family before ranking the family with the other procedures performed on the same day (for example, if multiple endoscopies in the same family are reported on the same day as endoscopies in another family or on the same day as a non-endoscopic procedure). If an endoscopic procedure is reported with only its base procedure, do not pay separately for the base procedure. Payment for the base procedure is included in the payment for the other endoscopy."                                                                                                                                                                                                       
#>  [5] "Special rules for the technical component (TC) of diagnostic imaging procedures apply if procedure is billed with another diagnostic imaging procedure in the same family (per the diagnostic imaging family indicator, below). If procedure is reported in the same session on the same day as another procedure with the same family indicator, rank the procedures by fee schedule amount for the TC. Pay 100% for the highest priced procedure, and 50% for each subsequent procedure. Base the payment for subsequent procedures on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage. Subject to 50% reduction of the TC diagnostic imaging (effective for services July 1, 2010 and after). Subject to 25% reduction of the PC of diagnostic imaging (effective for services January 1, 2012 through December 31, 2016). Subject to 5% reduction of the PC of diagnostic imaging (effective for services January 1, 2017 and after)."
#>  [6] "Subject to 50% of the practice expense component for certain therapy services."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#>  [7] "Subject to 25% reduction of the second highest and subsequent procedures to the TC of diagnostic cardiovascular services, effective for services January 1, 2013, and thereafter."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#>  [8] "Subject to 20% reduction of the second highest and subsequent procedures to the TC of diagnostic ophthalmology services, effective for services January 1, 2013, and thereafter."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#>  [9] NA                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> [10] "Concept does not apply"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            

# Co-Surgeon (Mod 62)
recode_cosurg(c(0:3, "9"))
#> [1] "Not Permitted"                           
#> [2] "Medical Necessity Documentation Required"
#> [3] "Permitted"                               
#> [4] NA                                        
#> [5] "Concept does not apply"                  

# Assistant Surgery (Mods 80-82, AS)
recode_asst(c(0:2, "9"))
#> [1] "Payment Restriction unless Medical Necessity documentation submitted"
#> [2] "Payment Restriction; Assistant cannot be paid"                       
#> [3] "No Payment Restriction; Assistant can be paid"                       
#> [4] "Concept does not apply"                                              
```
