# Recode Indicators

Recode Indicators

## Usage

``` r
recode_mod(x, which = c("name", "description"))

recode_glob(x, which = c("name", "description"))

recode_team(x)

recode_bilat(x, which = c("name", "description"))

recode_mult(x, which = c("name", "description"))

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
#> [1] "Not Permitted"              "Requires Medical Necessity"
#> [3] "Permitted"                 

# Bilateral Surgery (Mod 50)
recode_bilat(0:3)
#> [1] "No Adjustment" "Adjustment"    "No Adjustment" "No Adjustment"

# Multiple Procedure (Mod 51)
recode_mult(0:7)
#> [1] "No Adjustment"            "Standard Adjustment"     
#> [3] "Standard Adjustment"      "Multiple Endoscopy"      
#> [5] "Diagnostic Imaging"       "Therapy Reduction"       
#> [7] "Cardiovascular Reduction" "Ophthalmology Reduction" 

# Co-Surgeon (Mod 62)
recode_cosurg(0:2)
#> [1] "Not Permitted"              "Requires Medical Necessity"
#> [3] "Permitted"                 

# Assistant Surgery (Mods 80-82, AS)
recode_asst(0:2)
#> [1] "Requires Medical Necessity" "Assistant Not Paid"        
#> [3] "Assistant Paid"            

# Diagnostic Imaging Reduction (mult == 4)
recode_mult(4)
#> [1] "Diagnostic Imaging"
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
