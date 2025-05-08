## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.height = 3,
  fig.width = 5
)

## ----setup--------------------------------------------------------------------
library(ideanet)

## ----nw_flor, warning = FALSE, message = FALSE--------------------------------
nw_flor <- netwrite(nodelist = florentine_nodes,
                    node_id = "id",
                    i_elements = florentine_edges$source,
                    j_elements = florentine_edges$target,
                    type = florentine_edges$type,
                    directed = FALSE,
                    net_name = "florentine")

## ----flor_viz, eval = FALSE---------------------------------------------------
# igraph::plot.igraph(nw_flor$florentine)

## ----flor_partitions----------------------------------------------------------
flor_partitions <- get_partitions(nw_flor$florentine, n_runs = 500, seed = 4781)

## ----partition_counts---------------------------------------------------------
unlist(flor_partitions$count)
sum(unlist(flor_partitions$count))

## ----partition_query----------------------------------------------------------
flor_partitions$partitions[[2]]
flor_partitions$partitions[[10]]

## ----gamma_range--------------------------------------------------------------
print(flor_partitions$gamma_min)
print(flor_partitions$gamma_max)

## ----flor_CHAMP, warning = FALSE----------------------------------------------
flor_partitions <- CHAMP(nw_flor$florentine, flor_partitions, 
                         plottitle = "Florentine (combined)")

## ----flor_CHAMPsummary, eval = FALSE------------------------------------------
# print(flor_partitions$CHAMPsummary)

## ----flor_CHAMPsummary_kable, echo = FALSE------------------------------------
knitr::kable(flor_partitions$CHAMPsummary)

## ----partition7---------------------------------------------------------------
flor_partitions$partitions[[7]]
igraph::membership(flor_partitions$partitions[[7]])

## ----parition7_viz, eval = FALSE----------------------------------------------
# igraph::plot.igraph(nw_flor$florentine,mark.groups = flor_partitions$partitions[[7]])

## ----flor_CHAMPmap, warning = FALSE-------------------------------------------
flor_partitions <- get_CHAMP_map(nw_flor$florentine, flor_partitions, 
                                 plotlabel = "Florentine (combined)")

## ----flor_CHAMPsummary2, eval = FALSE-----------------------------------------
# print(flor_partitions$CHAMPsummary)

## ----flor_CHAMPsummary_kable2, echo = FALSE-----------------------------------
knitr::kable(flor_partitions$CHAMPsummary)

