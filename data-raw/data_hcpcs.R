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

# Add Sections and Ranges ---------------------
hcpcs_desc <- hcpcs_desc |>
  mutate(
    section = case_match(
      hcpcs,

      # Level I Codes
      as.character(99202:99499) ~ "Evaluation and Management",
      c(
        stringr::str_pad(100:1999, width = 5, pad = "0"),
        99100:99140
      ) ~ "Anesthesiology",
      as.character(10004:69990) ~ "Surgery",
      as.character(70010:79999) ~ "Radiology",
      as.character(80047:89398) ~ "Pathology and Laboratory",
      as.character(c(90281:99199, 99500:99607)) ~ "Medicine",

      ## Category I Immunization Codes (ends in A)
      paste0(
        stringr::str_pad(1:999, width = 4, pad = "0"),
        "A"
      ) ~ "Immunization",

      ## Category I Administrative MAAA Codes
      ## (Multianalyte Assays With Algorithmic Analyses Codes) (ends in M)
      paste0(
        stringr::str_pad(1:999, width = 4, pad = "0"),
        "M"
      ) ~ "Administrative Multianalyte Assay With Algorithmic Analysis",

      ## Category I Proprietary Laboratory Analyses (PLA) Codes (ends in U)
      paste0(
        stringr::str_pad(1:999, width = 4, pad = "0"),
        "U"
      ) ~ "Proprietary Laboratory Analysis",

      ## Category II Performance Measurement Codes (ends in F)
      paste0(
        stringr::str_pad(1:15, width = 4, pad = "0"),
        "F"
      ) ~ "Composite Measures",
      paste0(
        stringr::str_pad(500:584, width = 4, pad = "0"),
        "F"
      ) ~ "Patient Management",
      paste0(
        stringr::str_pad(1000:1505, width = 4, pad = "0"),
        "F"
      ) ~ "Patient History",
      paste0(
        stringr::str_pad(2000:2060, width = 4, pad = "0"),
        "F"
      ) ~ "Physical Examination",
      paste0(
        stringr::str_pad(3006:3776, width = 4, pad = "0"),
        "F"
      ) ~ "Diagnostic/Screening Processes or Results",
      paste0(
        stringr::str_pad(4000:4563, width = 4, pad = "0"),
        "F"
      ) ~ "Therapeutic, Preventive or Other Interventions",
      paste0(
        stringr::str_pad(5005:5250, width = 4, pad = "0"),
        "F"
      ) ~ "Follow-Up or Other Outcomes",
      paste0(
        stringr::str_pad(6005:6150, width = 4, pad = "0"),
        "F"
      ) ~ "Patient Safety",
      paste0(
        stringr::str_pad(7010:7025, width = 4, pad = "0"),
        "F"
      ) ~ "Structural Measures",
      paste0(
        stringr::str_pad(9001:9007, width = 4, pad = "0"),
        "F"
      ) ~ "Non-Measure Claims Based Reporting",

      ## Category III Temporary Codes (ends in T)
      paste0(
        stringr::str_pad(1:999, width = 4, pad = "0"),
        "T"
      ) ~ "Temporary Codes",

      # Level II Codes

      paste0(
        "A",
        stringr::str_pad(21:999, width = 4, pad = "0")
      ) ~ "Transportation Services Including Ambulance",
      paste0(
        "A",
        stringr::str_pad(2000:9999, width = 4, pad = "0")
      ) ~ "Medical and Surgical Supplies",

      paste0(
        "B",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Enteral and Parenteral Therapy",
      paste0(
        "C",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Outpatient PPS",
      paste0(
        "D",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Dental Codes",
      paste0(
        "E",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Durable Medical Equipment",
      paste0(
        "G",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Procedures/Professional Services (Temporary)",

      paste0(
        "H",
        stringr::str_pad(1:2037, width = 4, pad = "0")
      ) ~ "Alcohol and Drug Abuse Treatment Services",
      paste0(
        "H",
        stringr::str_pad(2038:2041, width = 4, pad = "0")
      ) ~ "Rehabilitative Services",

      paste0(
        "J",
        stringr::str_pad(120:8499, width = 4, pad = "0")
      ) ~ "Drugs Administered Other Than Oral Method",
      paste0(
        "J",
        stringr::str_pad(8501:9999, width = 4, pad = "0")
      ) ~ "Chemotherapy Drugs",

      paste0(
        "K",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Temporary DME Codes",
      paste0(
        "L",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Orthotic Procedures and Devices",

      paste0(
        "M",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Medical Services/Quality Measures",

      # paste0("M", stringr::str_pad(75:301, width = 4, pad = "0")) ~ "Medical Services",
      # paste0("M", stringr::str_pad(1003:1149, width = 4, pad = "0")) ~ "Quality Measures",

      paste0(
        "P",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Pathology and Laboratory",
      paste0(
        "Q",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Miscellaneous Services (Temporary)",
      paste0(
        "R",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Diagnostic Radiology Services",
      paste0(
        "S",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Commercial Payers (Temporary)",
      paste0(
        "T",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "State Medicaid Agency Codes",
      paste0(
        "U",
        stringr::str_pad(1:9999, width = 4, pad = "0")
      ) ~ "Coronavirus Lab Tests",

      paste0(
        "V",
        stringr::str_pad(2020:2799, width = 4, pad = "0")
      ) ~ "Vision Services",
      paste0(
        "V",
        stringr::str_pad(5008:5361, width = 4, pad = "0")
      ) ~ "Hearing Services",
      paste0(
        "V",
        stringr::str_pad(5362:5364, width = 4, pad = "0")
      ) ~ "Speech-Language Pathology Services",

      .default = NA_character_
    )
  )


#' Add Modifier Indicator Descriptions
#'
#' @param df data frame
#' @param col column of Modifier indicators
#' @return A [tibble][tibble::tibble-package] with an `mod_description` column
#' @examples
#' dplyr::tibble(mod = c(26, "TC", 53)) |>
#' case_modifier(mod)
#' @export
#' @autoglobal
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
