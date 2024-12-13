## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ideanet)

fauxmesa_edges <- fauxmesa_edges
fauxmesa_nodes <- fauxmesa_nodes

## ----glimpse_edges------------------------------------------------------------
dplyr::glimpse(fauxmesa_edges)

## ----glimpse_nodes------------------------------------------------------------
dplyr::glimpse(fauxmesa_nodes)

## ----nw_fauxmesa--------------------------------------------------------------
nw_fauxmesa <- netwrite(data_type = "edgelist",
                        nodelist = fauxmesa_nodes,
                        node_id = "id",
                        i_elements = fauxmesa_edges$from,
                        j_elements = fauxmesa_edges$to,
                        directed = TRUE,
                        net_name = "faux_mesa",
                        shiny = TRUE)


## ----system_measure_plot, fig.height = 4, fig.width=7-------------------------
nw_fauxmesa$system_measure_plot

## ----system_level_measures, eval = FALSE--------------------------------------
#  head(nw_fauxmesa$system_level_measures)

## ----system_level_measures_kable, echo = FALSE--------------------------------
knitr::kable(head(nw_fauxmesa$system_level_measures))

## ----igraph_object------------------------------------------------------------
nw_fauxmesa$faux_mesa

## ----plot_faux_mesa, fig.height = 4, fig.width = 4----------------------------
plot(nw_fauxmesa$faux_mesa,
     vertex.label = NA,
     vertex.size = 4,
     edge.arrow.size = 0.2,
     vertex.color = igraph::V(nw_fauxmesa$faux_mesa)$grade)

## ----largest_component, fig.height = 4, fig.width = 4-------------------------
plot(nw_fauxmesa$largest_component, vertex.label = NA, vertex.size = 2, edge.arrow.size = 0.2, 
     main = "Largest Component")

## ----largest_bi_component, fig.height = 4, fig.width = 4----------------------
plot(nw_fauxmesa$largest_bi_component, vertex.label = NA, vertex.size = 2, edge.arrow.size = 0.2, 
     main = "Largest Bicomponent")

## ----edgelist, eval = FALSE---------------------------------------------------
#  head(nw_fauxmesa$edgelist)

## ----edgelist_kable, echo = FALSE---------------------------------------------
knitr::kable(head(nw_fauxmesa$edgelist))

## ----node_measures, eval = FALSE----------------------------------------------
#  head(nw_fauxmesa$node_measures)

## ----node_measures_kable, echo = FALSE----------------------------------------
knitr::kable(head(nw_fauxmesa$node_measures))

## ----node_measure_plot, fig.height = 6, fig.width = 7-------------------------
nw_fauxmesa$node_measure_plot

## ----triad--------------------------------------------------------------------
triad

## ----nw_triad, warning = FALSE------------------------------------------------
nw_triad <- netwrite(data_type = "adjacency_matrix",
                     adjacency_matrix = triad,
                     directed = TRUE,
                     net_name = "triad_igraph",
                     shiny = TRUE)

## -----------------------------------------------------------------------------
plot(nw_triad$triad_igraph,
     edge.arrow.size = 0.2,
     vertex.label = NA)

## ----florentine_head, eval = FALSE--------------------------------------------
#  head(florentine_edges)

## ----florentine_head_kable, echo = FALSE--------------------------------------
knitr::kable(head(florentine_edges, n = 10))

## ----nw_flor, warning = FALSE-------------------------------------------------
nw_flor <- netwrite(nodelist = florentine_nodes,
                    node_id = "id",
                    i_elements = florentine_edges$source,
                    j_elements = florentine_edges$target,
                    type = florentine_edges$type,
                    directed = FALSE,
                    net_name = "florentine")

## ----edgelist_business, eval = FALSE------------------------------------------
#  head(nw_flor$edgelist$business)

## ----edgelist_business_kable, echo=FALSE--------------------------------------
knitr::kable(head(nw_flor$edgelist$business))

## ----edgelist_summary, eval = FALSE-------------------------------------------
#  head(nw_flor$edgelist$summary_graph)

## ----edgelist_summary_kable, echo = FALSE-------------------------------------
knitr::kable(head(nw_flor$edgelist$summary_graph))

## ----total_degree_type, echo = FALSE------------------------------------------
knitr::kable(nw_flor$node_measures %>% 
  dplyr::select(id, total_degree, marriage_total_degree, business_total_degree) %>%
  head())

## ----system_measures_multi, eval = FALSE--------------------------------------
#  head(nw_flor$system_level_measures)

## ----system_measures_multi_kable, echo=FALSE----------------------------------
knitr::kable(head(nw_flor$system_level_measures))

## ----flor_igraph1, fig.height = 4, fig.width = 7------------------------------
# Create a consistent layout for both plots
flor_layout <- igraph::layout.fruchterman.reingold(nw_flor$igraph_list$marriage)
plot(nw_flor$igraph_list$marriage, vertex.label = NA, vertex.size = 4, edge.arrow.size = 0.2, 
     vertex.color = "gray", main = "Marriage Network", layout = flor_layout)

## ----flor_igraph2, fig.height = 4, fig.width = 7------------------------------
plot(nw_flor$igraph_list$business, vertex.label = NA, vertex.size = 4, edge.arrow.size = 0.2, 
     vertex.color = "red", main = "Business Network", layout = flor_layout)

## ----fig.height = 6, fig.width = 7--------------------------------------------
flor_communities <- comm_detect(nw_flor$florentine)

## ----comm_summaries, eval = FALSE---------------------------------------------
#  flor_communities$summaries

## ----comm_summaries_kable, echo = FALSE---------------------------------------
knitr::kable(flor_communities$summaries)

## ----score_comparison, eval = FALSE-------------------------------------------
#  flor_communities$score_comparison

## ----score_comparison_kable, echo = FALSE-------------------------------------
knitr::kable(flor_communities$score_comparison)

## ----memberships, eval = FALSE------------------------------------------------
#  flor_communities$memberships

## ----memberships_kable, echo = FALSE------------------------------------------
knitr::kable(head(flor_communities$memberships))

## ----membership_merge, eval = FALSE-------------------------------------------
#  node_info <- nw_flor$node_measures %>%
#    dplyr::left_join(flor_communities$memberships, by = "id")

