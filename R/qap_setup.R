#' Individual to Dyadic variable transformation (\code{qap_setup}).
#'
#' @description The \code{qap_setup} function transform an individual level attributes into dyadic comparisons following a set of methods. Output can be used to compute QAP measurements using sister functions in \code{ideanet}.
#'
#' @param net An \code{igraph} or \code{network} object.
#' @param variables A vector of strings naming attributes to be transformed from individual-level to dyadic-level.
#' @param methods A vector of strings naming methods to be applied to the \code{variables} vector. The \code{methods} vector must be the same length as the \code{variables} vector. Methods are applied in order (e.g, first method is applied to the first named attribute in \code{variables}). Possible methods are "reduced_category", "multi_category", "both", and "difference". For more information about methods, consult the included vignette.
#' @param directed A logical statement identifying if the network should be treated as directed. Defaults to \code{FALSE}.
#' @param additional_vars A data frame containing additional individual-level variables not contained in the primary network input. Additional dataframe must contain an \code{id} or \code{label} variables which matches network exactly.
#' @return \code{qap_setup} returns a list of elements that include:
#'
#' - \code{graph}, an updated \code{igraph} object containing the newly constructed dyadic variables and additional individual-level variables.
#'
#' - \code{nodes}, a nodelist reflecting additional variables if included.
#'
#' - \code{edges}, a nodelist reflecting new dyadic variables.
#' @export
#'
#' @importFrom rlang .data
#' @importFrom data.table :=
#'
#' @examples
#'
#'
#' flor <- netwrite(nodelist = florentine_nodes,
#'                  node_id = "id",
#'                  i_elements = florentine_edges$source,
#'                  j_elements = florentine_edges$target,
#'                  type = florentine_edges$type,
#'                  directed = FALSE,
#'                  net_name = "florentine_graph")
#'
#' flor_setup <- qap_setup(flor$florentine_graph,
#'                         variables = c("total_degree"),
#'                         methods = c("difference"))

qap_setup <- function(net, variables = NULL, methods = NULL, directed = FALSE, additional_vars = NULL) {

  if (is.null(variables) | is.null(methods)) {
    stop("Variable or Methods is empty. Both must be of equal length.")
  }

  ### CONSTRUCTING NODE AND EDGE LISTS ###

  # Make sure it's an igraph object
  if ("network" %in% class(net)) {
    net <- intergraph::asIgraph(net)
  }

  # Create nodelist, checking for an "id" column
  if (!("id" %in% igraph::vertex_attr_names(net))) {
    nodes <- igraph::as_data_frame(net, what = "vertices") %>%
      tibble::rownames_to_column(var = "id") %>%
      dplyr::mutate(id = as.numeric(.data$id))
  } else {
    nodes <- igraph::as_data_frame(net, what = "vertices") %>%
      dplyr::mutate(id = as.numeric(.data$id))
  }

  # Create edgelist
  edges <- igraph::as_data_frame(net, what = "edges") %>%
    dplyr::mutate_at(dplyr::vars(.data$from, .data$to), as.numeric)

  # Check if additional_vars was called
  if (!is.null(additional_vars)) {
    vec1 <- nodes$id

    # Check if the called ego df has an id column or a label column
    tryCatch(vec2 <- additional_vars$id,
             warning = function(e)
               tryCatch(vec2 <- additional_vars$label,
                        warning = function(e)
                          stop("Make sure your additional ego dataframe contains an id or label variable")))

    # Check if the two ids are identical
    if (identical(vec1, vec2) == FALSE) {
      error_m <- paste0("Make sure the id or label of the additional ego dataframe match model ids exactly.
     There are ", length(vec1), " ids in the model and ", length(vec2), " ids in the additional
     dataframe, of which ", length(intersect(vec1, vec2)), " intersect.")
      stop(error_m)
    }

    # Merge if all tests are passed
    nodes <- nodes %>% dplyr::left_join(additional_vars)
  }

  ### CONSTRUCTING DYAD MEASURES FROM EGO MEASURES ###

  # check if there are as many variables as methods
  if ((length(variables) == length(methods)) == FALSE) {
    stop("Different number of variables and methods")
  }

  # loop over user defined variables
  for (i in 1:length(variables)) {
    variable <- variables[i]
    method <- methods[i]

    # Check (1) if variable in in nodelist (2) if variable NOT in edgelist (3) if transformed variable in edgelist. If False, skip.
    if (variable %in% names(nodes) & !(variable %in% names(edges)) & !(!!paste0(variable, "_ego") %in% names(edges))) {

      # Add each value with _ego or _alter suffix to edge dataframe
      edges <- edges %>%
        dplyr::left_join(nodes %>% dplyr::select(.data$id, tidyselect::all_of(variable)), by = c("from" = "id")) %>%
        dplyr::rename(!!paste0(variable, "_ego") := variable) %>%
        dplyr::left_join(nodes %>% dplyr::select(.data$id, tidyselect::all_of(variable)), by = c("to" = "id")) %>%
        dplyr::rename(!!paste0(variable, "_alter") := variable)

      # If method "reduced_category", create simple dichotomy
      if (method == "reduced_category") {
        edges <- edges %>%
          dplyr::mutate(!!rlang::sym((paste0("same_", variable))) :=
                          dplyr::case_when(!!rlang::sym(paste0(variable, "_alter")) ==
                                             !!rlang::sym(paste0(variable, "_ego")) ~ 1,
                                           is.na(!!rlang::sym(paste0(variable, "_ego"))) |
                                             is.na(!!rlang::sym(paste0(variable, "_alter"))) ~ NA_real_, TRUE ~ 0))
      }

      # If method "multi_category", create an tidyselect::all_of(variable) for each value and then dichotomize.
      if (method == "multi_category") {
        opts <- nodes %>% dplyr::select(tidyselect::all_of(variable)) %>% dplyr::distinct() %>% tidyr::drop_na() %>% dplyr::pull()

        for (n in 1:length(opts)) {
          edges <- edges %>%
            dplyr::mutate(!!rlang::sym((paste0("both_", variable, "_", opts[n]))) :=
                            dplyr::case_when((!!rlang::sym(paste0(variable, "_alter")) == opts[n]) &
                                               (!!rlang::sym(paste0(variable, "_ego")) == opts[n]) ~ 1,
                                             is.na(!!rlang::sym(paste0(variable, "_ego"))) |
                                               is.na(!!rlang::sym(paste0(variable, "_alter"))) ~ NA_real_, TRUE ~ 0))
        }
      }

      # If method "difference", take the difference between ego and alter
      if (method == "difference") {
        edges <- edges %>%
          dplyr::mutate(!!rlang::sym((paste0("diff_", variable))) :=
                          as.numeric(!!rlang::sym(paste0(variable, "_ego"))) -
                          as.numeric(!!rlang::sym(paste0(variable, "_alter"))),
                        !!rlang::sym((paste0("abs_diff_", variable))) :=
                          abs(as.numeric(!!rlang::sym(paste0(variable, "_ego"))) -
                          as.numeric(!!rlang::sym(paste0(variable, "_alter")))))
      }

      # If diff is "both", run both reduced and multi categories.
      if (method == "both") {
        edges <- edges %>%
          dplyr::mutate(!!rlang::sym((paste0("same_", variable))) :=
                          dplyr::case_when(!!rlang::sym(paste0(variable, "_alter")) ==
                                             !!rlang::sym(paste0(variable, "_ego")) ~ 1,
                                           is.na(!!rlang::sym(paste0(variable, "_ego"))) |
                                             is.na(!!rlang::sym(paste0(variable, "_alter"))) ~ NA_real_, TRUE ~ 0))

        opts <- nodes %>% dplyr::select(tidyselect::all_of(variable)) %>% dplyr::distinct() %>% tidyr::drop_na() %>% dplyr::pull()

        for (n in 1:length(opts)) {
          edges <- edges %>%
            dplyr::mutate(!!rlang::sym((paste0("both_", variable, "_", opts[n]))) :=
                            dplyr::case_when((!!rlang::sym(paste0(variable, "_alter")) == opts[n]) &
                                               (!!rlang::sym(paste0(variable, "_ego")) == opts[n]) ~ 1,
                                             is.na(!!rlang::sym(paste0(variable, "_ego"))) |
                                               is.na(!!rlang::sym(paste0(variable, "_alter"))) ~ NA_real_, TRUE ~ 0))
        }
      }
    }
  }

  qap_graph <- igraph::graph_from_data_frame(edges, directed = directed, vertices = nodes)
  qap_results <- list(graph = qap_graph, nodes = nodes, edges = edges)

  return(qap_results)
  # assign("qap_results", qap_results, .GlobalEnv)

}
