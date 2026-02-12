# Recode Indicators

Recode Indicators

## Usage

``` r
recode_mod(x, which = c("name", "description"))

recode_glob(x, which = c("name", "description"))

recode_team(x)

recode_bilat(x, which = c("name", "description"))

recode_mult(x)

recode_cosurg(x)

recode_asst(x)

recode_diag(x)

recode_pctc(x, which = c("name", "description"))

recode_status(x, which = c("name", "description"))
```

## Arguments

- x:

  `<chr>` vector of indicators

- which:

  `<chr>` which recoding to perform; one of `"name"` or `"description"`

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
# Modifier
recode_mod(c("26", "TC", "53"))
#> [1] "Professional Component" "Technical Component"    "Discontinued Procedure"
# Global Days
recode_glob(c(0, 1, 9, "M", "Y", "Z"))
#> [1] "Minor Procedure (Day-Of Postop)"          
#> [2] "Minor Procedure (10-Day Postop) "         
#> [3] "Major Surgery (90-Day Postop)"            
#> [4] "Maternity Code"                           
#> [5] "Carrier-Determined"                       
#> [6] "Included in Other Service's Global Period"
# Team Surgery (Mod 66)
recode_team(0:2)
#> [1] "Not Permitted"                           
#> [2] "Requires Medical Necessity Documentation"
#> [3] "Permitted"                               
# Bilateral Surgery (Mod 50)
recode_bilat(0:3)
#> [1] "No Adjustment" "Adjustment"    "No Adjustment" "No Adjustment"
# Multiple Procedure (Mod 51)
recode_mult(0:7)
#> [1] "No adjustment. If procedure is reported on the same day as another procedure, base the payment on the lower of (a) the actual charge, or (b) the fee schedule amount for the procedure."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
#> [2] "Standard adjustment. If reported on the same day as another procedure with an indicator of 1, 2, or 3, rank the procedures by fee schedule amount and apply the appropriate reduction to this code (100%, 50%, 25%, 25%, 25%, and by report). Base payment on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
#> [3] "Standard adjustment. If reported on the same day as another procedure with an indicator of 1, 2, or 3, rank the procedures by fee schedule amount and apply the appropriate reduction to this code (100%, 50%, 50%, 50%, 50% and by report). Base payment on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> [4] "Special rules for multiple endoscopic procedures apply if procedure is billed with another endoscopy in the same family (i.e., another endoscopy that has the same base procedure). The base procedure for each code with this indicator is identified in the Endobase column. Apply the multiple endoscopy rules to a family before ranking the family with the other procedures performed on the same day (for example, if multiple endoscopies in the same family are reported on the same day as endoscopies in another family or on the same day as a non-endoscopic procedure). If an endoscopic procedure is reported with only its base procedure, do not pay separately for the base procedure. Payment for the base procedure is included in the payment for the other endoscopy."                                                                                                                                                                                                       
#> [5] "Special rules for the technical component (TC) of diagnostic imaging procedures apply if procedure is billed with another diagnostic imaging procedure in the same family (per the diagnostic imaging family indicator, below). If procedure is reported in the same session on the same day as another procedure with the same family indicator, rank the procedures by fee schedule amount for the TC. Pay 100% for the highest priced procedure, and 50% for each subsequent procedure. Base the payment for subsequent procedures on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage. Subject to 50% reduction of the TC diagnostic imaging (effective for services July 1, 2010 and after). Subject to 25% reduction of the PC of diagnostic imaging (effective for services January 1, 2012 through December 31, 2016). Subject to 5% reduction of the PC of diagnostic imaging (effective for services January 1, 2017 and after)."
#> [6] "Subject to 50% of the practice expense component for certain therapy services."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#> [7] "Subject to 25% reduction of the second highest and subsequent procedures to the TC of diagnostic cardiovascular services, effective for services January 1, 2013, and thereafter."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#> [8] "Subject to 20% reduction of the second highest and subsequent procedures to the TC of diagnostic ophthalmology services, effective for services January 1, 2013, and thereafter."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
# Co-Surgeon (Mod 62)
recode_cosurg(0:2)
#> [1] "Not Permitted"                           
#> [2] "Requires Medical Necessity Documentation"
#> [3] "Permitted"                               
# Assistant Surgery (Mods 80-82, AS)
recode_asst(0:2)
#> [1] "Requires Medical Necessity Documentation"
#> [2] "Assistant Not Paid"                      
#> [3] "Assistant Paid"                          
# Diagnostic Imaging Reduction (mult == 4)
recode_mult(4)
#> [1] "Special rules for the technical component (TC) of diagnostic imaging procedures apply if procedure is billed with another diagnostic imaging procedure in the same family (per the diagnostic imaging family indicator, below). If procedure is reported in the same session on the same day as another procedure with the same family indicator, rank the procedures by fee schedule amount for the TC. Pay 100% for the highest priced procedure, and 50% for each subsequent procedure. Base the payment for subsequent procedures on the lower of (a) the actual charge, or (b) the fee schedule amount reduced by the appropriate percentage. Subject to 50% reduction of the TC diagnostic imaging (effective for services July 1, 2010 and after). Subject to 25% reduction of the PC of diagnostic imaging (effective for services January 1, 2012 through December 31, 2016). Subject to 5% reduction of the PC of diagnostic imaging (effective for services January 1, 2017 and after)."
recode_diag(1)
#> [1] "TC/PC Diagnostic Imaging Reduction"
# PC/TC Indicator
recode_pctc(0:8)
#> [1] "Physician Service"                      
#> [2] "Diagnostic Tests for Radiology Services"
#> [3] "Professional Component Only"            
#> [4] "Technical Component Only"               
#> [5] "Global Test Only"                       
#> [6] "Incident-To"                            
#> [7] "Lab Physician Interpretation"           
#> [8] "Physical Therapy"                       
#> [9] "Physician Interpretation"               
# Status Codes
recode_status(LETTERS[c(1:10, 13:14, 16, 18, 20, 24)])
#>  [1] "Active"                 "Payment Bundle"         "Carrier Priced"        
#>  [4] "Deleted Codes"          "Regulatory Exclusion"   "Deleted/Discontinued"  
#>  [7] "Not Valid for Medicare" "Deleted Modifier"       "Not Valid for Medicare"
#> [10] "Anesthesia Service"     "Measurement Code"       "Restricted Coverage"   
#> [13] "Non-Covered Service"    "Bundled/Excluded Code"  "Injections"            
#> [16] "Statutory Exclusion"   
```
