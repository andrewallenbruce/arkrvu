cheapr::fast_df(
  x = paste0("0", 1000:1999)
) |>
  collapse::mtt(
    x1 = substr(x, 1L, 1L),
    x2 = substr(x, 2L, 2L),
    x3 = substr(x, 3L, 3L),
    x4 = substr(x, 4L, 4L),
    x5 = substr(x, 5L, 5L)
  ) |>
  collapse::fcount(x5)

# Medicine
# grepl_(hcpcs, "^9[0-8][0-9]{3}$") | grepl_(hcpcs, "^99[01][0-9]{2}$") | grepl_(hcpcs, "^99[56][0-9]{2}$")
"^9[0-8][0-9]{3}$" # 90281:98999
"^99[01][0-9]{2}$" # 99000:99199
"^99[56][0-9]{2}$" # 99500:99607

# Anesthesiology
# grepl_(hcpcs, "^991[0-4][0-9]$") | grepl_(hcpcs, "^00[1-9][0-9]{2}$") | grepl_(hcpcs, "^01[0-9]{3}$")
"^991[0-4][0-9]$" # 99100:99140
"^00[1-9][0-9]{2}$" # 00100:00999
"^01[0-9]{3}$" # 01000:01999

cpt <- list(
  EM = c(99202:99498, "99499"),
  ANES = c(99100:99140, paste0("00", 100:999), paste0("0", 1000:1999)),
  SURG = c(10004:69989, "69990"),
  RAD = c(70010:79998, "79999"),
  PATH = c(
    80047:89398,
    paste0(
      c(paste0("000", 1:9), paste0("00", 10:99), paste0("0", 100:222)),
      "U"
    )
  ),
  MED = c(90281:99199, 99500:99606, "99607")
)

case_modifier <- function(df, col) {
  df |>
    dplyr::mutate(
      mod_description = dplyr::case_match(
        {{ col }},
        "26" ~ dplyr::tibble(
          mod_label = "Professional Component",
          mod_description = "Certain procedures are a combination of a physician or other qualified health care professional component and a technical component. When the physician or other qualified health care professional component is reported separately, the service may be identified by adding modifier 26 to the usual procedure number."
        ),
        "TC" ~ dplyr::tibble(
          mod_label = "Technical Component",
          mod_description = "Under certain circumstances, a charge may be made for the technical component alone. Under those circumstances the technical component charge is identified by adding modifier TC to the usual procedure number. Technical component charges are institutional charges and not billed separately by physicians; however, portable x-ray suppliers only bill for technical component and should utilize modifier TC. The charge data from portable x-ray suppliers will then be used to build customary and prevailing profiles."
        ),
        "53" ~ dplyr::tibble(
          mod_label = "Discontinued Procedure",
          mod_description = "Under certain circumstances, the physician or other qualified health care professional may elect to terminate a surgical or diagnostic procedure. Due to extenuating circumstances or those that threaten the well being of the patient, it may be necessary to indicate that a surgical or diagnostic procedure was started but discontinued. This circumstance may be reported by adding modifier 53 to the code reported by the individual for the discontinued procedure."
        )
      ),
      .after = {{ col }}
    ) |>
    tidyr::unpack(cols = mod_description)
}

#' Add PCTC Indicator Descriptions
#'
#' @param df data frame
#' @param col column of PCTC indicators
#' @return A [tibble][tibble::tibble-package] with a `pctc_description` column
#' @examples
#' dplyr::tibble(pctc = as.character(0:9)) |>
#' case_pctc(pctc)
#' @export
#' @autoglobal
case_pctc <- function(df, col) {
  df |>
    dplyr::mutate(
      pctc_description = dplyr::case_match(
        {{ col }},
        "0" ~ dplyr::tibble(
          pctc_label = "Physician Service",
          pctc_description = "PCTC does not apply."
        ),
        "1" ~ dplyr::tibble(
          pctc_label = "Diagnostic Tests for Radiology Services",
          pctc_description = "Have both a PC and TC. Mods 26/TC can be used. RVU components: Code + Mod -26 [wRVU, pRVU, mRVU]; Code + Mod -TC [pRVU, mRVU]; Code [wRVU, pRVU, mRVU]"
        ),
        "2" ~ dplyr::tibble(
          pctc_label = "Professional Component Only",
          pctc_description = "Standalone code. Describes PC of diagnostic tests for which there is a code that describes TC of diagnostic test only and another code that describes the Global test. RVU components: wRVU, pRVU, mRVU"
        ),
        "3" ~ dplyr::tibble(
          pctc_label = "Technical Component Only",
          pctc_description = "Standalone code. Mods 26/TC cannot be used. Describe TC of diagnostic tests for which there is a code that describes PC of the diagnostic test only. Also identifies codes that are covered only as diagnostic tests and do not have a PC code. RVU components: pRVU, mRVU"
        ),
        "4" ~ dplyr::tibble(
          pctc_label = "Global Test Only",
          pctc_description = "Standalone code. Describes diagnostic tests for which there are codes that describe PC of the test only, and the TC of the test only. Mods 26/TC cannot be used. Total RVUs is sum of total RVUs for PC and TC only codes combined. RVU components: wRVU, pRVU, mRVU"
        ),
        "5" ~ dplyr::tibble(
          pctc_label = "Incident To",
          pctc_description = "Services provided by personnel working under physician supervision. Payment may not be made when provided to hospital inpatients or outpatients. Mods 26/TC cannot be used."
        ),
        "6" ~ dplyr::tibble(
          pctc_label = "Lab Physician Interpretation",
          pctc_description = "Clinical Lab codes for which separate payment for interpretations by laboratory physicians may be made. Actual performance of tests paid by lab fee schedule. Mod TC cannot be used. RVU components: wRVU, pRVU, mRVU"
        ),
        "7" ~ dplyr::tibble(
          pctc_label = "Physical Therapy",
          pctc_description = "Payment may not be made if provided to hospital outpatient/inpatient by independently practicing physical or occupational therapist."
        ),
        "8" ~ dplyr::tibble(
          pctc_label = "Physician Interpretation",
          pctc_description = "Identifies PC of Clinical Lab codes for which separate payment made only if physician interprets abnormal smear for hospital inpatient. No TC billing recognized, payment for test made to hospital. No payment for CPT 85060 furnished to hospital outpatients or non-hospital patients. Physician interpretation paid through clinical laboratory fee schedule."
        ),
        "9" ~ dplyr::tibble(
          pctc_label = NA_character_, # "Not Applicable",
          pctc_description = NA_character_ # "PCTC Concept does not apply"
        )
      ),
      .after = {{ col }}
    ) |>
    tidyr::unpack(cols = pctc_description)
}

usethis::use_data(data_hcpcs, overwrite = TRUE)
