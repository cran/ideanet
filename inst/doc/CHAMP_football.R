## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.height = 3,
  fig.width = 5
)

## ----setup--------------------------------------------------------------------
library(ideanet)

## ----eval = FALSE-------------------------------------------------------------
# football

## ----football_viz, eval = FALSE-----------------------------------------------
# igraph::plot.igraph(football, main="Div-IA College Football, Fall 2000")

## ----warning = FALSE, eval = FALSE--------------------------------------------
# football_partitions <- get_partitions(football, n_runs = 500, seed = 115)
# football_partitions <- CHAMP(football, football_partitions,
#                              plottitle="Div-IA College Football, Fall 2000")
# football_partitions <- get_CHAMP_map(football, football_partitions,
#                                      plotlabel="Div-IA College Football, Fall 2000")

## ----warning = FALSE----------------------------------------------------------
football_partitions <- get_partitions(football, n_runs = 500, 
                                      gamma_range = c(0,7), seed = 115)
football_partitions <- CHAMP(football, football_partitions,
                             plottitle="Div-IA College Football, Fall 2000")
football_partitions <- get_CHAMP_map(football, football_partitions,
                                     plotlabel="Div-IA College Football, Fall 2000")
print(football_partitions$CHAMPsummary)

## ----football_partitions_viz, eval = FALSE------------------------------------
# colrs <- c("#543005", "#8C510A", "#BF812D", "#DFC27D", "#F6E8C3", "#C7EAE5", "#80CDC1", "#35978F", "#01665E", "#003C30")
# igraph::V(football)$color <- colrs[igraph::V(football)$value+1]
# igraph::plot.igraph(football,mark.groups = football_partitions$partitions[[27]],
#                     vertex.label=NA, vertex.size=5)

## ----football_table-----------------------------------------------------------
table(igraph::V(football)$value,
      igraph::membership(football_partitions$partitions[[27]]))

## ----community7---------------------------------------------------------------
igraph::V(football)$label[football_partitions$partitions[[27]]$membership == 7]

## ----uconn--------------------------------------------------------------------
UConn_nbhd <- unlist(igraph::neighborhood(football, 
                        nodes = which(igraph::V(football)$label=="Connecticut")))
igraph::V(football)$label[UConn_nbhd]

## ----community11--------------------------------------------------------------
igraph::V(football)$label[football_partitions$partitions[[27]]$membership == 11]

## ----community12--------------------------------------------------------------
igraph::V(football)$label[football_partitions$partitions[[27]]$membership == 12]

## ----table36_41---------------------------------------------------------------
table(igraph::membership(football_partitions$partitions[[27]]),
      igraph::membership(football_partitions$partitions[[31]]))

## ----table36_33---------------------------------------------------------------
table(igraph::membership(football_partitions$partitions[[27]]),
      igraph::membership(football_partitions$partitions[[24]]))

## -----------------------------------------------------------------------------
igraph::V(football)$label[football_partitions$partitions[[27]]$membership == 10]

