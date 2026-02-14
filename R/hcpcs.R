#' Validate HCPCS Codes
#'
#' @section HCPCS Codes:
#'    * 5 characters long
#'    * Begin with one of `[A-CEGHJ-MP-V0-9]`
#'    * Followed by any 3 digits, `[0-9]{3}`
#'    * End with one of `[AFMTU0-9]`
#'
#' @section HCPCS Level I (CPT) Codes:
#'    * Begin with any 4 digits, `[0-9]{4}`
#'    * End with one of `[AFMTU0-9]`
#'
#' HCPCS Level I is comprised of CPT (Current Procedural Terminology), a uniform
#' numeric coding system maintained by the AMA, consisting of terms and codes
#' that are used to identify medical services and procedures furnished by physicians
#' and other health care professionals, to bill public or private health insurance
#' programs. Level I does not include codes needed to separately report medical
#' items or services that are regularly billed by suppliers other than physicians.
#'
#' @section HCPCS Level II Codes:
#'    * Begin with one of `[A-CEGHJ-MP-V]`
#'    * Ends with any 4 digits, `[0-9]{4}`
#'
#' HCPCS Level II is a standardized coding system that is used primarily to
#' identify products, supplies, and services not included in the Level I CPT
#' codes, including ambulance services, durable medical equipment, prosthetics,
#' orthotics, and supplies (DMEPOS) when used outside a physician's office.
#'
#' Level II codes are also referred to as alpha-numeric codes because they
#' consist of a single alphabetical letter followed by 4 numeric digits, while
#' CPT codes are identified using 5 numeric digits.
#'
#' @section CPT Category I Codes:
#'    * Begins with any 4 digits, `[0-9]{4}`, and
#'    * Ends with one of `[AMU0-9]`
#'
#' @section CPT Category II Codes:
#'    * Begins with any 4 digits, `[0-9]{4}`, and
#'    * Ends with an `[F]`
#'
#' Category II codes are supplemental tracking codes that are used to track
#' services on claims for performance measurement and are not billing codes.
#'
#' These codes are intended to facilitate data collection about quality of care
#' by coding certain services and/or test results that support performance
#' measures and that have been agreed upon as contributing to good patient care.
#'
#' Some codes in this category may relate to compliance by the health care
#' professional with state or federal law. The use of these codes is optional.
#' The codes are not required for correct coding and may not be used as a
#' substitute for Category I codes.
#'
#' Services/procedures or test results described in this category make use of
#' alpha characters as the 5th character in the string (i.e., 4 digits followed
#' by an alpha character).
#'
#' These digits are not intended to reflect the placement of the code in the
#' regular (Category I) part of the CPT code set.
#'
#' Also, these codes describe components that are typically included in an
#' evaluation and management service or test results that are part of the
#' laboratory test/procedure. Consequently, they do not have a relative value
#' associated with them.
#'
#' @source [AMA Category II Codes](https://www.ama-assn.org/practice-management/cpt/category-ii-codes)
#'
#' @section CPT Category III Codes:
#'    * Begins with any 4 digits, `[0-9]{4}`, and
#'    * Ends with a `[T]`
#'
#' CPT Category III codes are a set of temporary codes that allow data
#' collection for emerging technologies and are used in the the Food and Drug
#' Administration (FDA) approval process.
#'
#' No RVUs are assigned to these codes and payment is based on payer policy. If
#' a Category III code is available, it must be reported in place of a Category
#' I unlisted code.
#'
#' The procedure/service they describe may not meet the following Category I
#' requirements:
#'
#'  - Necessary devices/drugs have received FDA clearance/approval.
#'  - It is performed by many US physicians/QHPs, at a frequency consistent with intended clinical use.
#'  - It is consistent with current medical practice.
#'  - It's clinical efficacy is documented in CPT-approved literature.
#'
#' @source [AMA Category III Codes](https://www.ama-assn.org/practice-management/cpt/category-iii-codes)
#'
#' @name hcpcs
#'
#' @param hcpcs `<chr>` vector of possible HCPCS codes
#'
#' @returns `<lgl>` `TRUE` if valid, otherwise `FALSE`
#'
#' @examples
#' x <- c("T1503", "G0478", "81301", "69641", "0583F", "0779T", NA, "1164")
#' y <- c("39503", "99215", "99140", "70010", "0222U", "V5299", "7010F")
#'
#' is_hcpcs(x)
#' is_hcpcs_I(x)
#' is_hcpcs_II(x)
#' is_cpt_I(x)
#' is_cpt_II(x)
#' is_cpt_III(x)
#'
#' fastplyr::new_tbl(
#'   hcpcs = c(x, y),
#'   type = hcpcs_level(hcpcs)) |>
#'   collapse::mtt(
#'     type = cheapr::if_else_(
#'       type == "HCPCS I",
#'       cpt_category(hcpcs),
#'       type),
#'     section = cheapr::if_else_(
#'       type != "HCPCS II",
#'       cpt_section(hcpcs),
#'       hcpcs_section(hcpcs))) |>
#'   collapse::roworder(type, hcpcs)
NULL

#' @rdname hcpcs
#' @export
is_hcpcs <- function(hcpcs) {
  grepl_(hcpcs, "^[A-EGHJ-MP-V]\\d{3}[AFMTU0-9]$")
}

#' @rdname hcpcs
#' @export
is_hcpcs_I <- function(hcpcs) {
  grepl_(hcpcs, "^\\d{4}[AFMTU0-9]$")
}

#' @rdname hcpcs
#' @export
is_hcpcs_II <- function(hcpcs) {
  grepl_(hcpcs, "^[A-EGHJ-MP-V]\\d{4}$")
}

#' @rdname hcpcs
#' @export
is_cpt_I <- function(hcpcs) {
  grepl_(hcpcs, "^\\d{4}[AMU0-9]$")
}

#' @rdname hcpcs
#' @export
is_cpt_II <- function(hcpcs) {
  grepl_(hcpcs, "^\\d{4}F$")
}

#' @rdname hcpcs
#' @export
is_cpt_III <- function(hcpcs) {
  grepl_(hcpcs, "^\\d{4}T$")
}

#' @rdname hcpcs
#' @export
hcpcs_type <- function(hcpcs) {
  cheapr::case(
    is_hcpcs_I(hcpcs) ~ "CPT",
    is_hcpcs_II(hcpcs) ~ "HCPCS",
    .default = NA_character_
  )
}

#' @rdname hcpcs
#' @export
hcpcs_level <- function(hcpcs) {
  cheapr::case(
    is_hcpcs_I(hcpcs) ~ "HCPCS I",
    is_hcpcs_II(hcpcs) ~ "HCPCS II",
    .default = NA_character_
  )
}

#' @rdname hcpcs
#' @export
cpt_category <- function(hcpcs) {
  cheapr::case(
    is_cpt_I(hcpcs) ~ "CPT I",
    is_cpt_II(hcpcs) ~ "CPT II",
    is_cpt_III(hcpcs) ~ "CPT III",
    .default = NA_character_
  )
}

#' @rdname hcpcs
#' @export
hcpcs_section <- function(hcpcs) {
  cheapr::val_match(
    substr(hcpcs, 1L, 1L),
    "A" ~ "Transport, Supplies",
    "B" ~ "Enteral, Parenteral",
    "C" ~ "OPPS",
    "D" ~ "Dental",
    "E" ~ "DME",
    "G" ~ "Professional",
    "H" ~ "Rehabilitative",
    "J" ~ "Non-Oral, Chemotherapy Drugs",
    "K" ~ "DME",
    "L" ~ "Orthotic, Prosthetic",
    "M" ~ "Medical, Quality",
    "P" ~ "Path/Lab",
    "Q" ~ "Misc",
    "R" ~ "Diag. Radiology",
    "S" ~ "Private Payer",
    "T" ~ "Medicaid",
    "U" ~ "Corona Labs",
    "V" ~ "Vision-Hearing-Speech",
    .default = NA_character_
  )
}

#' @noRd
is_cpt_anes <- function(hcpcs) {
  grepl_(hcpcs, "^991[0-4][0-9]$") |
    grepl_(hcpcs, "^00[1-9][0-9]{2}$") |
    grepl_(hcpcs, "^01[0-9]{3}$")
}

#' @noRd
is_cpt_med <- function(hcpcs) {
  grepl_(hcpcs, "^9[0-8][0-9]{3}$") |
    grepl_(hcpcs, "^99[01][0-9]{2}$") |
    grepl_(hcpcs, "^99[56][0-9]{2}$")
}

#' @noRd
is_cpt_maaa <- function(hcpcs) {
  endsWith(hcpcs, "M")
}

#' @rdname hcpcs
#' @export
cpt_section <- function(hcpcs) {
  cheapr::case(
    grepl_(hcpcs, "^99[2-4][0-9]{2}$") ~ "E&M",
    is_cpt_anes(hcpcs) ~ "Anesthesiology",
    grepl_(hcpcs, "^[1-6][0-9]{4}$") ~ "Surgery",
    grepl_(hcpcs, "^7[0-9]{4}$") ~ "Radiology",
    grepl_(hcpcs, "^8[0-9]{4}$") ~ "Pathology",
    is_cpt_med(hcpcs) ~ "Medicine",
    grepl_(hcpcs, "^0[012][0-9]{2}U$") ~ "Laboratory",
    endsWith(hcpcs, "A") ~ "Immunization",
    endsWith(hcpcs, "F") ~ "Performance Measurement",
    is_cpt_maaa(hcpcs) ~ "MAAA", # "Multianalyte Assay With Algorithmic Analysis",
    endsWith(hcpcs, "T") ~ "New Technology",
    .default = NA_character_
  )
}
