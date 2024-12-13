## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----nw_fauxmesa, warning = FALSE---------------------------------------------
library(ideanet)

nw_fauxmesa <- netwrite(nodelist = fauxmesa_nodes,
                        node_id = "id",
                        i_elements = fauxmesa_edges$from,
                        j_elements = fauxmesa_edges$to,
                        directed = FALSE,
                        net_name = "faux_mesa",
                        shiny = TRUE)

## ----var_meth, eval = FALSE---------------------------------------------------
#  var_methods <- data.frame(variable = c("sex", "race", "grade"),
#                            method = c("reduced_category", "multi_category", "difference"))
#  
#  var_methods

## ----var_meth_kable, echo = FALSE---------------------------------------------
var_methods <- data.frame(variable = c("sex", "race", "grade"),
                          method = c("reduced_category", "multi_category", "difference"))

knitr::kable(var_methods)

## ----qap_setup----------------------------------------------------------------
faux_qap_setup <- qap_setup(net = nw_fauxmesa$faux_mesa,
                            variables = var_methods$variable,
                            methods = var_methods$method,
                            directed = FALSE)

## ----qap_edgelist, eval = FALSE-----------------------------------------------
#  head(faux_qap_setup$edges)

## ----qap_edgelist_kable, echo = FALSE-----------------------------------------
knitr::kable(head(faux_qap_setup$edges))

## ----qap_run------------------------------------------------------------------
faux_qap <- qap_run(net = faux_qap_setup$graph,
                    dependent = NULL,
                    variables = c("same_sex", "both_race_White", "abs_diff_grade"),
                    directed = FALSE,
                    family = "linear")

## ----qap_results, eval = FALSE------------------------------------------------
#  faux_qap$covs_df

## ----qap_results_kable, echo = FALSE------------------------------------------
knitr::kable(faux_qap$covs_df)

## ----mods_df, eval = FALSE----------------------------------------------------
#  faux_qap$mods_df

## ----mods_df_kable, echo = FALSE----------------------------------------------
knitr::kable(faux_qap$mods_df)

