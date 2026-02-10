#' Check that input is 5 characters long
#' @param x `<chr>` string
#' @inheritParams rlang::args_error_context
#' @noRd
check_nchars <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (any(nchar(x) != 5L, na.rm = TRUE)) {
    cli::cli_abort(
      "{.arg {arg}} must be 5 characters long.",
      arg = arg,
      call = call
    )
  }
}

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
#' @name hcpcs_checks
#'
#' @param hcpcs `<chr>` vector of possible HCPCS codes
#'
#' @returns `<lgl>` `TRUE` if valid, otherwise `FALSE`
#'
#' @examples
#' x <- c('T1503', 'G0478', '81301', '69641', '0583F', '0779T', NA)
#'
#' is_hcpcs(x)
#'
#' x[which(is_hcpcs(x))]
#'
#' try(is_hcpcs("1164"))
#'
#' is_hcpcs_level_I(x)
#' is_hcpcs_level_II(x)
#' is_cpt_category_I(x)
#' is_cpt_category_II(x)
#' is_cpt_category_III(x)
NULL

#' @rdname hcpcs_checks
#' @export
is_hcpcs <- function(hcpcs) {
  check_nchars(hcpcs)

  grepl(
    "^[A-CEGHJ-MP-V0-9]\\d{3}[AFMTU0-9]$",
    toupper(hcpcs),
    perl = TRUE
  )
}

#' @rdname hcpcs_checks
#' @export
is_hcpcs_level_I <- function(hcpcs) {
  is_hcpcs(hcpcs) & grepl("^\\d{4}[AFMTU0-9]$", toupper(hcpcs), perl = TRUE)
}

#' @rdname hcpcs_checks
#' @export
is_hcpcs_level_II <- function(hcpcs) {
  is_hcpcs(hcpcs) & grepl("^[A-CEGHJ-MP-V]\\d{4}$", toupper(hcpcs), perl = TRUE)
}

#' @rdname hcpcs_checks
#' @export
is_cpt_category_I <- function(hcpcs) {
  is_hcpcs_level_I(hcpcs) &
    grepl("^\\d{4}[AMU0-9]$", toupper(hcpcs), perl = TRUE)
}

#' @rdname hcpcs_checks
#' @export
is_cpt_category_II <- function(hcpcs) {
  is_hcpcs_level_I(hcpcs) & grepl("^\\d{4}[F]$", toupper(hcpcs), perl = TRUE)
}

#' @rdname hcpcs_checks
#' @export
is_cpt_category_III <- function(hcpcs) {
  is_hcpcs_level_I(hcpcs) & grepl("^\\d{4}[T]$", toupper(hcpcs), perl = TRUE)
}
