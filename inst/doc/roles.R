## ----setup--------------------------------------------------------------------
library(ideanet)

## ----flor_data, eval = FALSE--------------------------------------------------
# head(florentine_nodes)
# head(florentine_edges)

## ----flor_node_kable, echo=FALSE----------------------------------------------
knitr::kable(head(florentine_nodes))

## ----flor_edge_kable, echo=FALSE----------------------------------------------
knitr::kable(head(florentine_edges))

## ----warning = FALSE, message = FALSE-----------------------------------------
nw_flor <- netwrite(nodelist = florentine_nodes,
                    node_id = "id",
                    i_elements = florentine_edges$source,
                    j_elements = florentine_edges$target,
                    type = florentine_edges$type,
                    directed = FALSE,
                    net_name = "florentine")

## ----flor_cluster, warning = FALSE--------------------------------------------
flor_cluster <- role_analysis(method = "cluster",
                              graph = nw_flor$igraph_list,
                              nodes = nw_flor$node_measures,
                              directed = FALSE,
                              min_partitions = 2,
                              max_partitions = 7,
                              viz = TRUE,
                              cluster_summaries = TRUE,
                              fast_triad = TRUE)

## ----cluster_assignments, eval = FALSE----------------------------------------
# head(flor_cluster$cluster_assignments)

## ----cluster_assignments_kable, echo = FALSE----------------------------------
knitr::kable(head(flor_cluster$cluster_assignments))

## ----dendrogram---------------------------------------------------------------
flor_cluster$cluster_dendrogram

## ----cluster_modularity-------------------------------------------------------
flor_cluster$cluster_modularity

## ----cluster_summaries, eval = FALSE------------------------------------------
# flor_cluster$cluster_summaries

## ----cluster_summaries_kable, echo = FALSE------------------------------------
knitr::kable(flor_cluster$cluster_summaries)

## ----cent_marriage, warning = FALSE-------------------------------------------
flor_cluster$cluster_summaries_cent$marriage

## ----cent_business, warning = FALSE-------------------------------------------
flor_cluster$cluster_summaries_cent$business

## ----cent_summary, warning = FALSE--------------------------------------------
flor_cluster$cluster_summaries_cent$summary_graph

## ----triad_marriage, warning = FALSE, eval = FALSE----------------------------
# flor_cluster$cluster_summaries_triad$marriage

## ----triad_business, warning = FALSE, eval = FALSE----------------------------
# flor_cluster$cluster_summaries_triad$business

## ----triad_summary, warning = FALSE-------------------------------------------
flor_cluster$cluster_summaries_triad$summary_graph

## ----igraph_viz---------------------------------------------------------------
igraph::V(nw_flor$florentine)$role <- flor_cluster$cluster_assignments$best_fit
plot(nw_flor$florentine, 
     vertex.color = as.factor(igraph::V(nw_flor$florentine)$role),
     vertex.label = NA)

## ----heatmap1, fig.width=7----------------------------------------------------
flor_cluster$cluster_relations_heatmaps$chisq # Chi-squared

## ----heatmap2, eval = FALSE---------------------------------------------------
# flor_cluster$cluster_relations_heatmaps$density # Density

## ----heatmap3, fig.width=7----------------------------------------------------
flor_cluster$cluster_relations_heatmaps$density_std # Density (Standardized)

## ----heatmap4, eval = FALSE---------------------------------------------------
# flor_cluster$cluster_relations_heatmaps$density_centered # Density (Zero-floored)

## ----warning = FALSE, fig.show = "hide", message = FALSE----------------------
flor_concor <- role_analysis(method = "concor",
                             graph = nw_flor$igraph_list,
                             nodes = nw_flor$node_measures,
                             directed = FALSE,
                             min_partitions = 1,
                             max_partitions = 4,
                             viz = TRUE)

## ----block_assignments, eval = FALSE------------------------------------------
# flor_concor$concor_assignments %>%
#   dplyr::select(id, family, dplyr::starts_with("block"), best_fit)

## ----block_assignments_kable, echo = FALSE------------------------------------
knitr::kable(flor_concor$concor_assignments %>%
  dplyr::select(id, family, dplyr::starts_with("block"), best_fit))

## ----concor_modularity--------------------------------------------------------
flor_concor$concor_modularity

## ----concor_sociogram, eval = FALSE-------------------------------------------
# igraph::V(nw_flor$florentine)$concor <- flor_concor$concor_assignments$best_fit
# plot(nw_flor$florentine,
#      vertex.color = as.factor(igraph::V(nw_flor$florentine)$concor),
#      vertex.label = NA)

## ----concor_tree, eval = FALSE------------------------------------------------
# flor_concor$concor_block_tree

## ----concor_heatmap1, fig.width=7---------------------------------------------
flor_concor$concor_relations_heatmaps$chisq

## ----concor_heatmap2, eval = FALSE--------------------------------------------
# flor_concor$concor_relations_heatmaps$density

## ----concor_heatmap3, fig.width=7---------------------------------------------
flor_concor$concor_relations_heatmaps$density_std

## ----concor_heatmap4, eval = FALSE--------------------------------------------
# flor_concor$concor_relations_heatmaps$density_centered

## ----concor_sociogram2--------------------------------------------------------
igraph::V(nw_flor$florentine)$concor2 <- flor_concor$concor_assignments$block_2
plot(nw_flor$florentine, 
     vertex.color = as.factor(igraph::V(nw_flor$florentine)$concor2),
     vertex.label = NA)

