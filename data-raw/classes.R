#' Node objects for collecting within trees
#'
#' These objects aren't particularly useful on their own, and are usually
#' called automatically assign a unique index.
#'
#' @param index The index of the node in the list of nodes stored in the tree
#' object. Calculated automatically when.
#'
#' @param value Any data or other attributes associated with the node.
#'
#' @param parent Integer: the index of the node's parent. Only one root node is
#' allowed per tree.
#'
#' @param children Integer: the index of any children of the node. Leaf nodes
#' should have a value of `NA_integer_`.
#'
#' @return An object of class `"arkrvu::hcpcs", "S7_object"`
#'
#' @examples
#' hcpcs("A0000")
#'
#' hcpcs(0L, list(a = 2))
#'
#' @export hcpcs
hcpcs <- S7::new_class(
  "hcpcs",
  properties = list(
    code         = S7::class_character,
    mod          = S7::class_character,
    status       = S7::class_character,
    rvu_work     = S7::class_numeric,
    rvu_pe_non   = S7::class_numeric,
    rvu_pe_fac   = S7::class_numeric,
    rvu_mp       = S7::class_numeric,
    pctc         = S7::class_character,
    glob_days    = S7::class_character,
    pre_op       = S7::class_numeric,
    intra_op     = S7::class_numeric,
    post_op      = S7::class_numeric,
    mult_proc    = S7::class_character,
    bilat_surg   = S7::class_character,
    asst_surg    = S7::class_character,
    co_surg      = S7::class_character,
    team_surg    = S7::class_character,
    endo_base    = S7::class_character,
    diag_img_fam = S7::class_character,
    opps_pe_non  = S7::class_numeric,
    opps_pe_fac  = S7::class_numeric,
    opps_mp      = S7::class_numeric
  ),
  validator = function(self) {
    if (length(self@code) != 1) { "@code must be length 1" }
    if (nchar(self@code) != 5) { "@code must have 5 characters" }
  },
  package = "arkrvu"
)

dplyr::glimpse(get_pin("rvu_source_2024")$files$pprvu)

pprvu <- get_pin("rvu_source_2024")$files$pprvu

pprvu_columns <- names(pprvu$rvu24a_jan) #stringr::str_c(names(pprvu$rvu24a_jan), sep = ", ", collapse = ", ")

rlang::as_data_mask(pprvu$rvu24a_jan)

rlang::syms(pprvu_columns)

pprvu$rvu24a_jan |>
  hacksaw::count_split(!!!rlang::list2(pprvu_columns))

#' Tree objects
#'
#' This is the primary class implemented in this package.
#'
#' @param nodes A list of nodes, as created via [node()], which form a tree.
#'
#' @return An object of class `"dendro::tree", "S7_object"`
#'
#' @examples
#' tree()
#' tree(list(node(1L)))
#'
#' @export tree
tree <- S7::new_class(
  "tree",
  properties = list(
    size = S7::new_property(
      S7::class_integer,
      getter = function(self) {
        self@nodes |>
          length()
      }
    ),
    node_indices = S7::new_property(
      S7::class_integer,
      getter = function(self) {
        unlist(lapply(self@nodes, \(x) x@index))
      }
    ),
    next_idx = S7::new_property(
      S7::class_integer,
      getter = function(self) {
        if (self@size == 0) return(1L)
        max(self@node_indices) + 1L
      }
    ),
    root = S7::new_property(
      S7::class_integer,
      getter = function(self) {
        if (self@size == 0) return(NA_integer_)
        if (self@size == 1) return(self@nodes[[1]]@index)

        get_nodes(self) |>
          vapply(
            \(x) x@parent,
            integer(1)
          ) |>
          is.na() |>
          which()

      }
    ),
    nodes = S7::class_list
  ),
  validator = function(self) {
    if (length(self@root) == 0) {
      "@root is of length 0; did you forget to start by adding the parent node?"
    } else if (length(self@root) != 1) {
      "@root is longer than 1; did you accidentally add unconnected nodes?"
    }
  },
  package = "dendro"
)
