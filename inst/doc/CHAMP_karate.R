## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.height = 3,
  fig.width = 5
)

## ----setup--------------------------------------------------------------------
library(ideanet)

## ----karate_prep, message = FALSE---------------------------------------------
data(karate, package="igraphdata")
karate <- igraph::delete_edge_attr(karate, "weight")

## ----karate_viz, eval = FALSE-------------------------------------------------
# igraph::plot.igraph(karate, main="Zachary's Karate Club")

## ----karate_partitions--------------------------------------------------------
kc_partitions <- get_partitions(karate, n_runs = 500, seed = 3478)

## ----karateCHAMP, warning = FALSE---------------------------------------------
kc_partitions <- CHAMP(karate, kc_partitions, 
                       plottitle = "Zachary's Karate Club (unweighted)")

## ----karate_CHAMPsummary, eval = FALSE----------------------------------------
# print(kc_partitions$CHAMPsummary)

## ----karate_CHAMPsummary_kable, echo = FALSE----------------------------------
knitr::kable(kc_partitions$CHAMPsummary)

## ----partition6---------------------------------------------------------------
kc_partitions$partitions[[6]]
igraph::membership(kc_partitions$partitions[[6]])

## ----partition6viz, eval = FALSE----------------------------------------------
# igraph::plot.igraph(karate,mark.groups = kc_partitions$partitions[[6]])

## ----warning = FALSE----------------------------------------------------------
kc_partitions <- get_CHAMP_map(karate, kc_partitions, 
                               plotlabel = "Zachary's Karate Club (unweighted)")

## ----karate_CHAMPsummary2, eval = FALSE---------------------------------------
# print(kc_partitions$CHAMPsummary)

## ----karate_CHAMPsummary_kable2, echo = FALSE---------------------------------
knitr::kable(kc_partitions$CHAMPsummary)

## ----karate_viz2, eval = FALSE------------------------------------------------
# data(karate,package="igraphdata")
# igraph::plot.igraph(karate, main="Zachary's Karate Club (weighted)")
# kcw_partitions <- get_partitions(karate, n_runs = 500, seed = 3478)
# kcw_partitions <- CHAMP(karate,kcw_partitions,
#                         plottitle="Zachary's Karate Club (weighted)")
# kcw_partitions <- get_CHAMP_map(karate,kcw_partitions,
#                                 plotlabel="Zachary's Karate Club (weighted)")

