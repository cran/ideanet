#' Find the SBM-equivalence iterative map on the CHAMP set of somewhere optimal partitions
#'
#' @description \code{get_CHAMP_map} calculates the iterative map defined by Newman's equivalence between modularity optimization and inference on the degree-corrected planted partition stochastic block model on a \cite{CHAMP} set of partitions. That is, given an input set of partitions of nodes in a network into communities, calculated by \cite{get_partitions} or by other means and coerced into that format, \code{CHAMP} identifies which input partition is optimal at each value of the resolution parameter, gamma, and then \code{get_CHAMP_map} calculates the iterative map of this set onto itself. Importantly, a fixed point of this map, where a partition points to itself, indicates that partition is self-consistent in the sense of this equivalence between modularity and planted partition models. As with \code{CHAMP}, the \code{get_CHAMP_map} code is deterministic and fast given a specified input set of partitions; that is, all of the computational complexity and pseudo-stochastic heuristic nature of community detection is in identifying a good input set in \cite{get_partitions}.
#'
#' The \code{CHAMP} method was developed and studied in Weir, William H., Scott Emmons, Ryan Gibson, Dane Taylor, and Peter J. Mucha. “Post-Processing Partitions to Identify Domains of Modularity Optimization.” Algorithms 10, no. 3 (August 19, 2017): 93. \doi{10.3390/a10030093}.
#'
#' The equivalence between modularity optimization and planted partition inference was derived by M. E. J. Newman in “Equivalence between Modularity Optimization and Maximum Likelihood Methods for Community Detection.” Physical Review E 94, no. 5 (November 22, 2016): 052315. \doi{10.1103/PhysRevE.94.052315}.
#'
#' The iterative map on the CHAMP set was developed and studied in Gibson, Ryan A., and Peter J. Mucha. “Finite-State Parameter Space Maps for Pruning Partitions in Modularity-Based Community Detection.” Scientific Reports 12, no. 1 (September 23, 2022): 15928. \doi{10.1038/s41598-022-20142-6}.
#'
#' See also \url{https://github.com/wweir827/CHAMP} and \url{https://github.com/ragibson/ModularityPruning}.
#'
#' @param network The network, as igraph object, to be clustered into communities. Only undirected networks are currently supported. If the object has a 'weight' edge attribute, then that attribute will be used, though it is important to emphasize that the underlying equivalence between modularity and planted partitons defining the iterative map was derived for unweighted networks.
#' @param partitions List of unique partitions with CHAMP summary generated by \code{CHAMP}.
#' @param plotlabel Optional label to include as annotation on the generated figure.
#' @param shiny A logical value indicating whether \code{get_CHAMP_map} is being called within \code{ideanetViz}. If \code{TRUE}, \code{get_CHAMP_map} returns an output data frame that \code{ideanetViz} uses for visualization.
#'
#' @returns \code{get_CHAMP_map} returns the input list of partitions with the \code{$CHAMPsummary} updated to indicate the iterative map, that is, information about the next partition that each partition points to in the map, along with the generated \code{$CHAMPmap} plot of the partitions in the CHAMP set (by their numbers of communities) versus gamma. If \code{shiny = TRUE}, the returned list also includes a data frame entitled \code{shiny_partitions} that is used for visualizations in \code{ideanetViz}.
#' @import igraphdata
#'
#' @author Peter J. Mucha (\email{peter.j.mucha@dartmouth.edu}), Alex Craig, Rachel Matthew, Sydney Rosenbaum and Ava Scharfstein
#'
#' @export
#'
#' @examples
#' # Use get_partitions, CHAMP, and get_CHAMP_map to generate
#' # multiple partitions of the Zachary karate club and identify
#' # the domains of optimality in the resolution parameter for
#' # different partitions
#' data(karate, package = "igraphdata")
#' partitions <- get_partitions(karate, n_runs = 2500)
#' partitions <- CHAMP(karate, partitions, plottitle = "Weighted Karate Club")
#' partitions <- get_CHAMP_map(karate, partitions, plotlabel = "Weighted Karate Club")

###############################
#   G E T  C H A M P  M A P   #
###############################

#PJM: 8.8.2024. Gathered bits of code from Alex Craig, Rachel Matthew, Sydney Rosenbaum and Ava Scharfstein into add_champ branch
#PJM: 8.19.2024. Edits to add warning for weighted networks and to allow network to be unweighted (instead of treating unweighted graphs as weight=1)
#PJM: 3.13.2025. Fixed case where the network might have multiple components

# Expects to receive partitions as obtained by get_partitions.R followed by CHAMP.R.
get_CHAMP_map <- function( network,
                           partitions,
                           plotlabel=NULL,
                           shiny = FALSE){

  if (igraph::is_weighted(network)) {
    if (stats::sd(igraph::E(network)$weight) != 0) {
      warning("The theory underlying get_CHAMP_map() is for unweighted networks. The formulae have been naturally generalized to weighted networks, but these have not been well studied.\n")
    }
  }

  partition_summary <- partitions$CHAMPsummary #as generated by CHAMP.R

  numcomponents <- igraph::components(network)$no
  for (x in 1:nrow(partition_summary)) {
    if (partition_summary[x, "num_communities"] > numcomponents) {
      partition <- partitions$partitions[[partition_summary[x, "partition_num"]]]
      res_param <- derive_res_parameter(partition, network)

      partition_summary[x, "next_gamma"] <- res_param  # gamma stored

      # determining which cluster corresponds to said gamma...
      idx <- which( (res_param > partition_summary$starting_gamma) &
                      (res_param<=partition_summary$ending_gamma) )
      #... and storing it in the summary
      partition_summary[x, "next_partition_num"] <- partition_summary[idx, "partition_num"]
      partition_summary[x, "next_num_communities"] <- partition_summary[idx, "num_communities"]
    }
  }
  # partition_summary is now updated to carry this data for all partitions

  #PRINT FIXED POINTS:
  for (x in 1:nrow(partition_summary)) {
    if (!is.na(partition_summary[x, "next_gamma"]) &&
        partition_summary[x, "next_gamma"] > partition_summary[x, "starting_gamma"] &&
        partition_summary[x, "next_gamma"] < partition_summary[x, "ending_gamma"]) {
      pnum <- partition_summary[x, "partition_num"]
      #plot(partitions$partitions[[pnum]],
      #     network,
      #     main = str_c("Partition", pnum, "with", partition_summary[x, "num_communities"],
      #                  "clusters", sep = " "))
      print(paste("Partition #",pnum,"(with",partition_summary[x,"num_communities"],
                  "communities) is a fixed point of the iterative map"))
    }
  }

  #PLOTTING:
  plot_data.1 <- data.frame(
    x = sort(c(partition_summary$starting_gamma, partition_summary$ending_gamma)),
    y = sort(c(partition_summary$num_communities, partition_summary$num_communities)),
    group = sort(c(1:nrow(partition_summary), 1:nrow(partition_summary))),
    color = sort(c(1:nrow(partition_summary), 1:nrow(partition_summary)))
  )

  plot_data.2 <- data.frame(
    x1 = stats::na.omit(partition_summary)$next_gamma,
    y1 = stats::na.omit(partition_summary)$next_num_communities
  )

  x2 <- c();  y2 <- c(); ends <- c()
  for (x in rownames(partition_summary)){
    p <- partition_summary[x,]
    if (!is.na(p$next_gamma)) {
      x2 <- append(x2, (p$starting_gamma + p$ending_gamma)/2)
      x2 <- append(x2, p$next_gamma)
      y2 <- append(y2, p$num_communities)
      y2 <- append(y2, p$next_num_communities)
      if ((p$starting_gamma + p$ending_gamma)/2 > p$next_gamma) {
        ends <- append(ends, "first")
      } else { ends <- append(ends, "last") }
    }
  }

  plot_data.3 <- data.frame( x2 = x2, y2 = y2, group = sort(c(1:length(x2), 1:length(x2))))

  palette <- sample(grDevices::colors()[c(1:151, 362:657)], lengths(partition_summary)[1], replace=T)
  ggfig <- ggplot2::ggplot(data = plot_data.1) +
    ggplot2::geom_line(ggplot2::aes(x = .data$x, y = .data$y, group = .data$group, color=palette[plot_data.1$color]), linewidth=2) +
    ggplot2::geom_point(ggplot2::aes(x = .data$x, y = .data$y, color=palette[plot_data.1$color]), shape=4, size=2, stroke=2) +
    ggplot2::geom_point(data = plot_data.2, ggplot2::aes(x = plot_data.2$x1, y = plot_data.2$y1), size=2, stroke=1) +
    ggplot2::geom_line(data=plot_data.3, ggplot2::aes(x = plot_data.3$x2, y = plot_data.3$y2, group = plot_data.3$group),
              linewidth=1, color="darkgray",
              arrow = ggplot2::arrow(length = ggplot2::unit(0.5, "cm"), ends = ends)) +
    ggplot2::guides(color = "none") +
    ggplot2::labs(x = expression(gamma),
         y = "Number of communities",
         title = expression(paste("CHAMP Domains of Optimality and ",gamma," Estimates")))+
    ggthemes::theme_few() +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 8)) +
    ggplot2::annotation_custom(grid::textGrob(plotlabel, x=0.05, y=0.9, hjust=0))
  print(ggfig)

  #print(partition_summary)
  partitions$CHAMPsummary <- partition_summary
  partitions$CHAMPmap <- ggfig

  # Create dataframe for `ideanetViz` visualization
  if (isTRUE(shiny)) {

    ### Get fixed points identified in `CHAMPsummary`
    fixed_points <- partition_summary[partition_summary$partition_num == partition_summary$next_partition_num, ]
    fixed_points <- fixed_points[!is.na(fixed_points$partition_num),]
    fixed_points <- fixed_points$partition_num

    ### For reach fixed point...
    for (i in 1:length(fixed_points)) {
      ### Extract this partitioning from `partitions`
      this_partition <- partitions$partitions[[fixed_points[i]]]
      ### Create dataframe of community memberships for this partitioning
      this_df <- data.frame(id = this_partition$name,
                            partition = this_partition$membership)
      ### Rename columns to reflect partitioning level
      colnames(this_df) <- c("id", paste("champ", fixed_points[i], sep = ""))

      ### If `i == 1`, create new dataframe for `ideanetViz` purposes
      if (i == 1) {
        shiny_partitions <- this_df
        ### Otherwise merge `this_df` into this output dataframe
      } else {
        shiny_partitions <- shiny_partitions %>%
          dplyr::left_join(this_df, by = "id")
      }
    }

    ### Ensure `id` is numeric to allow merging with `node_measures`
    ### dataframe created by `netwrite`
    shiny_partitions$id <- as.numeric(shiny_partitions$id)

    # Store `shiny_partitions` in overall output
    partitions$shiny_partitions <- shiny_partitions

  }

  return(partitions)

}

###################################

# Parameters:
# - partition: a partition from which to compute the resolution parameter
# - network: the network on which the partition is placed
derive_res_parameter <- function(partition, network) {

  if (partition$nb_clusters > 1) {
    #m <- sum(igraph::E(network)$weight)
    m <- sum(igraph::strength(network))/2
    m.in <- 0
    k2.c <- 0
    for (i in 1:partition$nb_clusters){
      partition_graph <- igraph::induced_subgraph(network,
                                                  igraph::V(network)[partition$membership == i])
      #m.in <- m.in + sum(igraph::E(partition_graph)$weight)
      m.in <- m.in + sum(igraph::strength(partition_graph))/2
      k2.c <- k2.c + ( sum(igraph::strength(network)[partition$membership == i]) )**2
    }
    m.out <- m - m.in

    theta.in <- 2*m.in / (k2.c/(2*m))
    theta.out <- 2*m.out / (2*m - k2.c/(2*m))

    parameter <- (theta.in - theta.out) / (log(theta.in) - log(theta.out))
    return (parameter)
  } else {
    return (NULL)
  }

}
