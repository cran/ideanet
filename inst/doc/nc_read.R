## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----nc_read, eval = FALSE----------------------------------------------------
#  nc_data <- nc_read(path = "~/Desktop/network_canvas_directory/",
#                     protocol = "~/Desktop/protocol_directory/nc_protocol.netcanvas"
#                     cat.to.factor = TRUE)

## ----nc_merge, eval = FALSE---------------------------------------------------
#  
#  nc_merge(path = "~/Desktop/network_canvas_directory/",
#           export_path = "~/Desktop/merged_network_canvas_directory/")
#  
#  
#  nc_data <- nc_read(path = "~/Desktop/merged_network_canvas_directory/",
#                     cat.to.factor = TRUE)

## ----ego_netwrite, eval = FALSE-----------------------------------------------
#  nc_netwrite <- ego_netwrite(egos = nc_data$egos,
#                              ego_id = "ego_id",
#                              alters = nc_data$alters,
#                              alter_id = "alter_id",
#                              alter_ego = "ego_id",
#                              alter_alter = nc_data$alter_edgelists,
#                              aa_ego = "ego_id",
#                              i_elements = "from",
#                              j_elements = "to")

## ----ego_netwrite_multi, eval = FALSE-----------------------------------------
#  # Extract ego list and pertinent alter list and alter-alter edgelists
#  egos <- nc_data$egos
#  people <- nc_data$alters$people
#  people_ties <- dplyr::bind_rows(nc_data$alter_edgelists$friends,
#                                  nc_data$alter_edgelists$family,
#                                  nc_data$alter_edgelists$romantic)
#  
#  # Feed these objects into `ego_netwrite` and indicate identifier variables
#  nc_people <- ego_netwrite(egos = egos,
#                              ego_id = "ego_id",
#                              alters = people,
#                              alter_id = "alter_id",
#                              alter_ego = "ego_id",
#                              alter_alter = people_ties,
#                              aa_ego = "ego_id",
#                              i_elements = "from",
#                              j_elements = "to",
#                              aa_type = "edge_type")

## ----ego_netwrite_vignette, eval = FALSE--------------------------------------
#  vignette("ego_netwrite", package = "ideanet")

## ----egor_install, eval = FALSE-----------------------------------------------
#  install.packages("egor")

## ----egor, eval = FALSE-------------------------------------------------------
#  # Create `egor` object
#  nc_egor <- egor::egor(alters = nc_data$alters,
#                            egos = nc_data$egos,
#                            aaties = nc_data$alter_edgelists,
#  
#                            ID.vars = list(
#                              ego = "ego_id",
#                              alter = "alter_id",
#                              source = "from",
#                              target = "to"
#                            ))
#  
#  # Inspect and analyze `egor` object
#  summary(nc_egor)
#  egor::ego_density(nc_egor)

## ----egor_mult, eval = FALSE--------------------------------------------------
#  
#  # Extract ego list and pertinent alter list and alter-alter edgelists
#  egos <- nc_data$egos
#  people <- nc_data$alters$people
#  
#  friends <- nc_data$alter_edgelists$friends
#  family <- nc_data$alter_edgelists$family
#  romantic <- nc_data$alter_edgelists$romantic
#  
#  # `egor` object for friendship ties
#  friends_egor <- egor::egor(alters = people,
#                            egos = egos,
#                            aaties = friends,
#  
#                            ID.vars = list(
#                              ego = "ego_id",
#                              alter = "alter_id",
#                              source = "from",
#                              target = "to"
#                            ))
#  
#  # `egor` object for family ties
#  family_egor <- egor::egor(alters = people,
#                            egos = egos,
#                            aaties = family,
#  
#                            ID.vars = list(
#                              ego = "ego_id",
#                              alter = "alter_id",
#                              source = "from",
#                              target = "to"
#                            ))
#  
#  # `egor` object for romantic ties
#  family_egor <- egor::egor(alters = people,
#                            egos = egos,
#                            aaties = romantic,
#  
#                            ID.vars = list(
#                              ego = "ego_id",
#                              alter = "alter_id",
#                              source = "from",
#                              target = "to"
#                            ))

