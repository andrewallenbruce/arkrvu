# https://www.cms.gov/medicare/physician-fee-schedule/search/documentation
#
# The payment formula is as follows:
#
# Budget Neutrality Adjustor Values
#
# 2006 & Earlier: N/A
# 2007: 0.8994
# 2008: 0.8806
# 2009 - 2024: N/A
# 2015: 0.9981


dplyr::tibble(
  year = c(2006, 2007,   2008,   2009:2014,                  2015,   2016:2024),
  bna  = c(NA,   0.8994, 0.8806, rep(NA, length(2009:2014)), 0.9981, rep(NA, length(2016:2024))
  )
)


# On March 9, 2024, President Biden signed the Consolidated Appropriations Act,
# 2024, which included a 2.93 percent update to the CY 2024 Physician Fee
# Schedule (PFS) Conversion Factor (CF) for
#
# dates of service March 9 through December 31, 2024. [2024-03-09, 2024-12-31]
#
# This replaces the 1.25 percent update provided by the Consolidated
# Appropriations Act, 2023, therefore the CY 2024 CF
#
# for dates of service January 1 through March 8, 2024 is $32.74.
#
# CMS has implemented the new legislation by adjusting the CY 2023 CF
# of $33.07 by 2.93 percent and the budget neutrality adjustment for a
# CY 2024 CF of $33.29
#
# for dates of service March 9 through December 31. [2024-03-09, 2024-12-31]
#
# CMS is also releasing updated payment files, including the MPFS and associated
# abstract files, the Ambulatory Surgical Center (ASC) FS, and Anesthesia file.

# Non-Facility Pricing Amount =
#   [(Work RVU * Work GPCI) +
#      (Non-Facility PE RVU * PE GPCI) +
#      (MP RVU * MP GPCI)] * Conversion Factor
#
# Facility Pricing Amount =
#   [(Work RVU * Work GPCI) +
#      (Facility PE RVU * PE GPCI) +
#      (MP RVU * MP GPCI)] * Conversion Factor

dplyr::tibble(
  price_type = c("non_facility", "facility"),
  formula = c(
    "[(Work RVU * Work GPCI) + (Non-Facility PE RVU * PE GPCI) + (MP RVU * MP GPCI)] * Conversion Factor",
    "[(Work RVU * Work GPCI) + (Facility PE RVU * PE GPCI) + (MP RVU * MP GPCI)] * Conversion Factor"
  )
)
