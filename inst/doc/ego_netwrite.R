## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----example_egos, echo = FALSE, fig.height = 6, fig.width = 7----------------
no_aa <- data.frame(ego = rep(1, 5),
                    alter = 2:6)
no_aa_graph <- igraph::graph_from_data_frame(no_aa, directed = FALSE)

plot(no_aa_graph,
     vertex.label = ifelse(igraph::V(no_aa_graph)$name == "1", "Ego", "Alter"),
     vertex.color = ifelse(igraph::V(no_aa_graph)$name == "1", "#FFCC00", "#99CCFF"),
     vertex.label.dist = 3,
     main = "Basic Ego Network"
     )

with_aa <- data.frame(ego = c(rep(1, 5), 2, 2, 4, 5),
                    alter = c(2:6, 3, 5, 2, 3))
with_aa_graph <- igraph::graph_from_data_frame(with_aa, directed = FALSE)

plot(with_aa_graph,
     vertex.label = ifelse(igraph::V(with_aa_graph)$name == "1", "Ego", "Alter"),
          vertex.color = ifelse(igraph::V(no_aa_graph)$name == "1", "#FFCC00", "#99CCFF"),
     vertex.label.dist = 3,
     main = "Ego Network with Alter-Alter Ties"
     )

## ----ego_reshape, eval = FALSE------------------------------------------------
# ?ego_reshape

## ----setup--------------------------------------------------------------------
library(ideanet) 

# Ego list
ngq_egos <- ngq_egos
# Alter list
ngq_alters <- ngq_alters
# Alter-alter edgelist
ngq_aa <- ngq_aa

## ----ngq_egos-----------------------------------------------------------------
dplyr::glimpse(ngq_egos)

## ----ngq_alters---------------------------------------------------------------
dplyr::glimpse(ngq_alters)

## ----ngq_aa-------------------------------------------------------------------
dplyr::glimpse(ngq_aa)

## ----ego28, eval = FALSE------------------------------------------------------
# ngq_aa %>%
#   dplyr::filter(ego_id == 4)

## ----ego28_knitr, echo = FALSE------------------------------------------------
knitr::kable(head(ngq_aa %>%
  dplyr::filter(ego_id == 4)))

## ----ngq_nw, warning=FALSE----------------------------------------------------
ngq_nw <- ego_netwrite(egos = ngq_egos,
                       ego_id = ngq_egos$ego_id,

                       alters = ngq_alters,
                       alter_id = ngq_alters$alter_id,
                       alter_ego = ngq_alters$ego_id,

                       max_alters = 10,
                       alter_alter = ngq_aa,
                       aa_ego = ngq_aa$ego_id,
                       i_elements = ngq_aa$alter1,
                       j_elements = ngq_aa$alter2,
                       directed = FALSE)

## ----egos, eval = FALSE-------------------------------------------------------
# head(ngq_nw$egos)

## ----egos_kable, echo = FALSE-------------------------------------------------
knitr::kable(head(ngq_nw$egos))

## ----alters, eval = FALSE-----------------------------------------------------
# head(ngq_nw$alters)

## ----alters_kable, echo = FALSE-----------------------------------------------
knitr::kable(head(ngq_nw$alters))

## ----alter_edgelist, eval = FALSE---------------------------------------------
# head(ngq_nw$alter_edgelist)

## ----alter_edgelist_knitr, echo = FALSE---------------------------------------
knitr::kable(head(ngq_nw$alter_edgelist))

## ----summaries, eval = FALSE--------------------------------------------------
# head(ngq_nw$summaries)

## ----summaries_kable, echo = FALSE--------------------------------------------
knitr::kable(head(ngq_nw$summaries))

## ----ego_merge, eval = FALSE--------------------------------------------------
# egos2 <- ngq_nw$egos %>%
#   dplyr::left_join(ngq_nw$summaries, by = "ego_id")
# 
# head(egos2)

## ----ego_merge_kable, echo = FALSE--------------------------------------------
egos2 <- ngq_nw$egos %>%
  dplyr::left_join(ngq_nw$summaries, by = "ego_id")

knitr::kable(head(egos2))

## ----overall, eval = FALSE----------------------------------------------------
# ngq_nw$overall_summary

## ----overall_kable, echo = FALSE----------------------------------------------
knitr::kable(ngq_nw$overall_summary)

## ----igraph1------------------------------------------------------------------
names(ngq_nw$igraph_objects[[1]])

## ----ego_search---------------------------------------------------------------
which(lapply(ngq_nw$igraph_objects, function(x){x$ego} == 4) == TRUE)

## ----ego_info, eval = FALSE---------------------------------------------------
# ngq_nw$igraph_objects[[4]]$ego_info

## ----ego_info_kable, echo = FALSE---------------------------------------------
knitr::kable(ngq_nw$igraph_objects[[4]]$ego_info)

## -----------------------------------------------------------------------------
ngq_nw$igraph_objects[[4]]$igraph

## ----fig.height = 4, fig.width = 4--------------------------------------------
ego4 <- ngq_nw$igraph_objects[[4]]$igraph_ego

plot(ego4,
     vertex.color = igraph::V(ego4)$sex,
     layout = igraph::layout.fruchterman.reingold(ego4))

## ----ngq_alters_el, echo = FALSE----------------------------------------------
knitr::kable(head(ngq_nw$ngq_alters))

## ----alter_types_nw, warning = FALSE------------------------------------------
alter_types_nw <- ego_netwrite(egos = ngq_egos,
                       ego_id = ngq_egos$ego_id,

                       alters = ngq_alters,
                       alter_id = ngq_alters$alter_id,
                       alter_ego = ngq_alters$ego_id,
                       # Note the inclusion of `alter_types` here
                       alter_types = c("family", "friend", "other_rel"),

                       max_alters = 10,
                       alter_alter = ngq_aa,
                       aa_ego = ngq_aa$ego_id,
                       i_elements = ngq_aa$alter1,
                       j_elements = ngq_aa$alter2,
                       directed = FALSE)

## ----summary_cors, echo = FALSE-----------------------------------------------
knitr::kable(head(alter_types_nw$summaries %>% dplyr::select(ego_id, dplyr::contains("cor"))))

## ----overall_summaries_rel1, echo = FALSE-------------------------------------
knitr::kable(alter_types_nw$overall_summary)

## ----multitype_el2, echo = FALSE----------------------------------------------
knitr::kable(ngq_aa %>%
  dplyr::filter(ego_id == 4) %>% dplyr::slice(1:6))

## ----aa_types_nw, warning = FALSE---------------------------------------------
aa_types_nw <- ego_netwrite(egos = ngq_egos,
                            ego_id = ngq_egos$ego_id,
    
                            alters = ngq_alters,
                            alter_id = ngq_alters$alter_id,
                            alter_ego = ngq_alters$ego_id,
    
                            max_alters = 10,
                            alter_alter = ngq_aa,
                            aa_ego = ngq_aa$ego_id,
                            i_elements = ngq_aa$alter1,
                            j_elements = ngq_aa$alter2,
                            # Note the inclusion of `aa_type` here
                            aa_type = ngq_aa$type,
                            directed = FALSE)

## ----aa_alters, echo = FALSE--------------------------------------------------
knitr::kable(head(aa_types_nw$alters))

## ----aa_summaries, echo = FALSE-----------------------------------------------
knitr::kable(head(aa_types_nw$summaries))

## ----aa_overall, echo=FALSE---------------------------------------------------
knitr::kable(aa_types_nw$overall_summary)

## ----aa_igraph_objects--------------------------------------------------------
names(aa_types_nw$igraph_objects[[1]])

## ----aa_igraph_plots, eval = FALSE--------------------------------------------
# ego7 <- aa_types_nw$igraph_objects[[7]]$igraph_ego
# ego7_friends <- aa_types_nw$igraph_objects[[7]]$igraph_ego_friends
# ego7_family <- aa_types_nw$igraph_objects[[7]]$igraph_ego_related
# ego7_other <- aa_types_nw$igraph_objects[[7]]$igraph_ego_other_rel
# 
# ego7_layout <- igraph::layout.fruchterman.reingold(ego7)
# 
# plot(ego7,
#      vertex.color = igraph::V(ego7)$sex,
#      layout = ego7_layout,
#      main = "Overall Network")
# 
# plot(ego7_friends,
#      vertex.color = igraph::V(ego7_friends)$sex,
#      layout = ego7_layout,
#      main = "Friends")
# 
# plot(ego7_family,
#      vertex.color = igraph::V(ego7_family)$sex,
#      layout = ego7_layout,
#      main = "Family")
# 
# plot(ego7_other,
#      vertex.color = igraph::V(ego7_other)$sex,
#      layout = ego7_layout,
#      main = "Other Relationships")

## ----aa_igraph_plots_kable, echo = FALSE, fig.height = 4, fig.width = 4-------
ego7 <- aa_types_nw$igraph_objects[[7]]$igraph_ego
ego7_friends <- aa_types_nw$igraph_objects[[7]]$igraph_ego_friends
ego7_family <- aa_types_nw$igraph_objects[[7]]$igraph_ego_related
ego7_other <- aa_types_nw$igraph_objects[[7]]$igraph_ego_other_rel

ego7_layout <- igraph::layout.fruchterman.reingold(ego7)

plot(ego7,
     vertex.color = igraph::V(ego7)$sex,
     layout = ego7_layout,
     main = "Overall Network")

plot(ego7_friends,
     vertex.color = igraph::V(ego7_friends)$sex,
     layout = ego7_layout,
     main = "Friends")

plot(ego7_family,
     vertex.color = igraph::V(ego7_family)$sex,
     layout = ego7_layout,
     main = "Family")

plot(ego7_other,
     vertex.color = igraph::V(ego7_other)$sex,
     layout = ego7_layout,
     main = "Other Relationships")

## ----h_index------------------------------------------------------------------
alters <- aa_types_nw$alters

# H-Index
race_h_index <- h_index(ego_id = alters$ego_id,
                        measure = alters$race,
                        prefix = "race")
# Index of Qualitative Variation (Normalized H-Index)
race_iqv <- iqv(ego_id = alters$ego_id,
                measure = alters$race,
                prefix = "race")

## ----homophily----------------------------------------------------------------
egos <- aa_types_nw$egos

# Ego Homophily (Count)
race_homophily_c <- ego_homophily(ego_id = egos$ego_id,
                                  ego_measure = egos$race,
                                  alter_ego = alters$ego_id,
                                  alter_measure = alters$race,
                                  prefix = "race",
                                  prop = FALSE)
# Ego Homophily (Proportion)
race_homophily_p <- ego_homophily(ego_id = egos$ego_id,
                                  ego_measure = egos$race,
                                  alter_ego = alters$ego_id,
                                  alter_measure = alters$race,
                                  prefix = "race",
                                  prop = TRUE)
# E-I Index
race_ei <- ei_index(ego_id = egos$ego_id,
                       ego_measure = egos$race,
                       alter_ego = alters$ego_id,
                       alter_measure = alters$race,
                       prefix = "race")
# Pearson's Phi
race_pphi <- pearson_phi(ego_id = egos$ego_id,
                            ego_measure = egos$race,
                            alter_ego = alters$ego_id,
                            alter_measure = alters$race,
                            prefix = "race")

## ----euc----------------------------------------------------------------------
# Euclidean Distance
pol_euc <- euclidean_distance(ego_id = egos$ego_id,
                              ego_measure = egos$pol,
                              alter_ego = alters$ego_id,
                              alter_measure = alters$pol,
                              prefix = "pol")

## ----homophily_merge----------------------------------------------------------
egos <- egos %>%
  dplyr::left_join(race_h_index, by = "ego_id") %>%
  dplyr::left_join(race_homophily_p, by = "ego_id") %>%
  dplyr::left_join(pol_euc, by = "ego_id")

## ----merge_kable, echo=FALSE--------------------------------------------------
knitr::kable(head(egos))

## ----egor_install, eval = FALSE-----------------------------------------------
# install.packages("egor")

## ----egor, eval = FALSE-------------------------------------------------------
# egor

## ----nc_read_vig, eval = FALSE------------------------------------------------
# vignette("nc_read", package = "ideanet")

