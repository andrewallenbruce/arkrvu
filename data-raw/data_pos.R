place_of_srvc <- northstar::search_pos() |>
  collapse::mtt(
    pos_type = as.character(pos_type),
    pos_type = cheapr::if_else_(
      pos_type == "Unassigned",
      NA_character_,
      pos_type
    ),
    pos_name = cheapr::if_else_(
      pos_name == "Unassigned",
      NA_character_,
      pos_name
    ),
    pos_description = cheapr::if_else_(
      pos_description == "Unassigned",
      NA_character_,
      pos_description
    )
  ) |>
  fastplyr::as_tbl()

place_of_srvc <- cheapr::sset(
  place_of_srvc,
  cheapr::row_na_counts(place_of_srvc) == 0L
)

# constructive::construct(place_of_srvc, constructive::opts_tbl_df("tribble"))

usethis::use_data(place_of_srvc, overwrite = TRUE)
