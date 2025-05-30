#' Find the Convex Hull of Admissible Modularity Partitions (\code{CHAMP})
#'
#' @description The Convex Hull of Admissible Modularity Partitions (\code{CHAMP}) method post-processes an input set of partitions as collected by \code{get_partitions} (or as formatted similarly from some other source of selected partitions) to identify the partitions that are somewhere optimal in the resolution parameter and the associated domains of (generalized) modularity optimization. That is, given the input set of partitions of nodes in a network into communities, \code{CHAMP} identifies which input partition is optimal at each value of the resolution parameter, gamma. Importantly, \code{CHAMP} is deterministic and polynomial in time given a specified input set of partitions; that is, all of the computational complexity and pseudo-stochastic heuristic nature of community detection is in identifying a good input set in \cite{get_partitions}.
#'
#' The \code{CHAMP} method was developed and studied in Weir, William H., Scott Emmons, Ryan Gibson, Dane Taylor, and Peter J. Mucha. “Post-Processing Partitions to Identify Domains of Modularity Optimization.” Algorithms 10, no. 3 (August 19, 2017): 93. \doi{10.3390/a10030093}.
#'
#' See also \url{https://github.com/wweir827/CHAMP} and \url{https://github.com/ragibson/ModularityPruning}.
#'
#' @param network The network, as igraph object, to be clustered into communities. Only undirected networks are currently supported. If the object has a 'weight' edge attribute, then that attribute will be used.
#' @param partitions A list of unique partitions (in the format generated by \code{get_partitions}).
#' @param plottitle Optional title for generated plot of (generalized) modularity versus resolution parameter.
#'
#' @returns \code{CHAMP} returns the input list of partitions with a \code{$CHAMPsummary} about which partitions are somewhere optimal (in the sense of modularity Q with a resolution parameter gamma) and their domains of optimality, along with the generated \code{$CHAMPfigure} plot of the upper envelope of Q(gamma). The returned list object also contains the original list entered into the \code{partitions} argument.
#' @import igraphdata
#'
#' @author Peter J. Mucha (\email{peter.j.mucha@dartmouth.edu}), Alex Craig, Rachel Matthew, Sydney Rosenbaum and Ava Scharfstein
#'
#' @export
#'
#' @examples
#' # Use get_partitions and CHAMP to generate multiple partitions of the
#' # Zachary karate club and identify the domains of optimality in the
#' # resolution parameter for different partitions
#' data(karate, package = "igraphdata")
#' partitions <- get_partitions(karate, n_runs = 500)
#' partitions <- CHAMP(karate, partitions, plottitle = "Weighted Karate Club")

#################
#   C H A M P   #
#################

#PJM: 7.30.2024. Gathered bits of code from Alex Craig, Rachel Matthew, Sydney Rosenbaum and Ava Scharfstein into add_champ branch
#PJM: 8.8.2024. Fixed error about not finding function "count" and changed output to instead add summary and plot to the input partitions variable
#PJM: 8.19.2024. Fixed unusual situation where nb_clusters does not appear to be the correct number of communities
#PJM: 8.19.2024. Fixed vertical axis tick labels
#PJM: 3.13.2025. Folding in Tom's suggested edits, as part of checking everything works with the new get_partitions that includes comm_detect results, and removed partitions that are only optimal for Q(gamma)<0

CHAMP <- function( network,
                   partitions,
                   plottitle=NULL){

# In the original CHAMP paper and python implementation, we use QHull to do the heavy lifting. But since we're only dealing with a 1D parameter space here (for single-layer networks; multilayer networks will be dealt with elsewhere), we can instead brute-force the identification of the upper envelope of the Q(gamma) lines. (See the paper for figures of this.) Importantly, our simple algorithm here searching for the next line crossing could fail in the (rare?) circumstance where three different partitions intersect on the upper envelope of Q(gamma) at the same point.

  # Check input network is undirected
  if (igraph::is_directed(network)) {stop("Input is directed. Only undirected networks are currently supported.")}

  mod_matrix <- data.frame(row.names = 1:length(partitions$partitions),
                           base = 1:length(partitions$partitions),
                           decrement = 1:length(partitions$partitions))

  for (k in 1:length(partitions$partitions)) {
    partition <- partitions$partitions[[k]];
    #VERY SLOW: ret <- partition_level_champ(network, partition)
    #mod_matrix[k, "base"] <- ret$a_partition
    #mod_matrix[k, "decrement"] <- ret$p_partition
    A <- igraph::modularity(network,igraph::membership(partitions$partitions[[k]]),
                            resolution=0,weights=igraph::E(network)$weight)
    Q <- igraph::modularity(network,igraph::membership(partitions$partitions[[k]]),
                            resolution=1,weights=igraph::E(network)$weight)
    # Note that the above E(network)$weight calls return NULL for unweighted graphs, which is then the proper, default input to the modularity function.
    mod_matrix[k, "base"] <- A
    mod_matrix[k, "decrement"] <- (A-Q)
  }

  #print(mod_matrix)

  # To start, gamma is set to 0. The modularity of each partition at this point is calculated.
  gam <- 0
  mods <- mod_matrix["base"] - gam*mod_matrix["decrement"]
  #print(paste("The modularities:", mods))

  # The maximum partition at this value of gamma is detected. because gamma=0 here, this is the first max-modularity partition in the range. mmp="maximum modularity partition".
  mmp <- which(mods==max(mods))[[1]]

  # Now simple algebra is used to compute when (at what value of gamma) each of the remaining partitions will have a greater modularity than the current max-modularity partition. In this case, this calculates when each other partition will overtake the first mmp.
  mod_matrix["tilmax"] <- (mod_matrix[mmp, "base"] - mod_matrix["base"])/
    (mod_matrix[mmp, "decrement"] - mod_matrix["decrement"])
  # The algorithm proceeds from left to right, so no values less than the current gamma need be visited, nor should the same partition as the current mmp be chosen. To avoid this:
  mod_matrix[mmp, "tilmax"] <- NaN
  mod_matrix[which(mod_matrix["tilmax"]<=gam), "tilmax"] <- NaN

  #print(mod_matrix)

  # If this leaves no more available partitions, then the loop ends here. If partitions are still available, we continue. The minimum value remaining of the partitions' tilmax is the smallest gamma at which a new partition becomes the mmp, so we shift our gamma value there and record the end of the previous mmp.
  gam <- min(mod_matrix["tilmax"], na.rm=T) + 10^-8
  #print(paste("partition", mmp, "is best from 0 to", gam))
  # note the added 10^-8 boost is necessary to ensure we have PASSED the end of the current mmp's range.

  # At this point the loop repeats, adjusting the mmp and repeating the process.
  mods <- mod_matrix["base"] - gam*mod_matrix["decrement"]
  #print(paste("The modularities:", mods))
  mmp <- which(mods==max(mods))[[1]]
  #print(paste(mmp, "is now the mmp."))

  # We repeat this process in find_max_for_CHAMP() below until no further partitions overtake the current mmp at a later gamma or until gamma exceeds a set range (the find_max_for_CHAMP function takes the gamma range as an argument)
  fmax <- find_max_for_CHAMP(mod_matrix, c(partitions$gamma_min,partitions$gamma_max))


  # Now for plotting purposes we re-do the whole thing brute-forced at equispaced gamma values
  gammas <- seq(partitions$gamma_min,partitions$gamma_max,
                (partitions$gamma_max-partitions$gamma_min)/200)
  a <- list(); p <- list(); k <- 0
  #Note this whole loop just recomputes items computed above. Could remove, but I don't think it's hurting anything.
  for (partition in partitions$partitions) {
    k <- k+1
    #VERY SLOW: ret <- partition_level_champ(network, partition)
    #a[k] <- ret$a_partition
    #p[k] <- ret$p_partition
    A <- igraph::modularity(network,igraph::membership(partitions$partitions[[k]]),
                            resolution=0,weights=igraph::E(network)$weight)
    Q <- igraph::modularity(network,igraph::membership(partitions$partitions[[k]]),
                            resolution=1,weights=igraph::E(network)$weight)
    a[k] <- A
    p[k] <- (A-Q)
  }

  modularity <- array(NA, dim = c(length(gammas), length(partitions$partitions)))
  for (k in 1:length(partitions$partitions)) {
    for (g in 1:length(gammas)) {
      modularity[g,k] <- a[[k]]-(gammas[g]*p[[k]])
    }
  }

  best_gammas <- fmax$edges
  best_gammas <- c(best_gammas[-length(best_gammas)], partitions$gamma_max)
  corresponding_partitions <- fmax$partitions
  best_modularities <- c()
  for (g in 1:length(best_gammas)) {
    partition_index <- corresponding_partitions[g]
    best_modularities[g] <- a[[partition_index]]-(best_gammas[g]*p[[partition_index]])
  }

  # Plot data frames
  all <- data.frame(x = gammas)
  for (i in 1:dim(modularity)[2]) {
    all <- cbind(all, i=modularity[,i])
  }
  colnames(all) <- c('x',paste("", 1:dim(modularity)[2], sep = ""))
  all <- reshape2::melt(all, id = 'x')
  colnames(all)[2] <- "partition_num"
  last <- corresponding_partitions[length(corresponding_partitions)]

  best_gammas <- c(partitions$gamma_min,best_gammas)
  best_modularities <- c(modularity[1,1], best_modularities)
  # Remove partitions/segments that are Q<0:
  test0 <- best_modularities<0
  if (sum(test0)) {
    last <- which(test0)[1]
    partition_index <- corresponding_partitions[last-1]
    best_modularities <- best_modularities[1:last]
    best_modularities[last] <- 0
    best_gammas <- best_gammas[1:last]
    best_gammas[last] <- a[[partition_index]]/p[[partition_index]]
    corresponding_partitions <- corresponding_partitions[1:(last-1)]
  }
  last <- length(best_modularities)
  best <- data.frame(best_gammas, best_modularities)
  # Copy everything into the segments data frame for plotting and processing:
  segments <- data.frame(x1 = best_gammas[1:(last-1)],
                         y1 = best_modularities[1:(last-1)],
                         x2 = best_gammas[2:last],
                         y2 = best_modularities[2:last],
                         partitions = corresponding_partitions)

  print(paste(last-1,
              "partitions in the CHAMP set (i.e., on the upper envelope of Q v. gamma)"))
  #print(partition_summary)

  title <- plottitle
  if (is.null(plottitle)) {title <- " "}

  ggfig <- ggplot2::ggplot()
  ggfig <- ggfig +
    ggplot2::geom_line(data = all,
                       mapping = ggplot2::aes(x = all$x,
                                              y = all$value,
                                              group = all$partition_num),
                       show.legend = F,
                       color = all$partition_num,
                       alpha = .3,
                       na.rm = T) +
    ggplot2::geom_segment(data = segments,
                          mapping = ggplot2::aes(x=segments$x1,
                                                 y=segments$y1,
                                                 xend = segments$x2,
                                                 yend = segments$y2),
                          color = "#63666A",
                          linewidth = 1.5,
                          na.rm = T) +
    ggplot2::geom_text(data = segments,
                       ggplot2::aes(x = (segments$x1+segments$x2)/2,
                                    y = (segments$y1+segments$y2)/2,
                                    label = segments$partitions),
                       color = segments$partitions,
                       vjust = -.5) +
    ggplot2::geom_segment(data = best,
                          mapping = ggplot2::aes(x = best$best_gammas,
                                                 xend = best$best_gammas,
                                                 y = best$best_modularities,
                                                 yend = -Inf),
                          linetype = "dashed",
                          color = "black",
                          na.rm = T) +
    ggplot2::geom_point(data = best,
                        mapping = ggplot2::aes(x = best$best_gammas,
                                               y = best$best_modularities),
                        color = "black",
                        na.rm = T) +
    ggplot2::labs(x = expression(paste("Resolution Parameter (", gamma,")")),
                  y = expression(paste("Modularity Q(", gamma,")")),
                  title = title)+
    ggplot2::scale_y_continuous(limits = c(0,max(segments$y1))) +
    ggplot2::scale_x_continuous(breaks = c(segments$x1,2),
                                labels = c(round(segments$x1,2),2),
                                limits = c(0,partitions$gamma_max),
                                expand = c(0,0)) +
    ggthemes::theme_few() +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 8))
  print(ggfig)

  partition_summary <- data.frame(matrix(ncol = 9, nrow = length(segments[,1])))
  colnames(partition_summary) <- c("starting_gamma", "ending_gamma",
                                   "partition_num", "num_communities",
                                   "next_gamma", "next_partition_num", "next_num_communities",
                                   "segment_length", "gamma_range")

  for (x in 1:nrow(partition_summary)) {

    partition_summary$segment_length[x] <- sqrt((segments[x, "x1"]-segments[x, "x2"])**2+(segments[x, "y1"]-segments[x, "y2"])**2)
    partition_summary$starting_gamma[x] <- segments[x,"x1"]
    partition_summary$ending_gamma[x] <- segments[x,"x2"]
    partition_summary$gamma_range[x] <- abs(segments[x,"x1"]-segments[x,"x2"])
    partition_summary$partition_num[x] <- segments[x,"partitions"]
    #partition_summary$num_communities[x] <- partitions$partitions[segments$partitions][[x]]$nb_clusters
    #partition_summary$num_communities[x] <- partitions$partitions[[segments[x,"partitions"]]]$nb_clusters
    #When creating the vignette, found a weighted karate instance with nb_clusters=4 but only 3 communities.
    partition_summary$num_communities[x] <- max(igraph::membership(
      partitions$partitions[[segments[x,"partitions"]]]))
  }

  #partition_summary <- partition_summary[order(-partition_summary$gamma_range),]

  partitions$CHAMPsummary <- partition_summary
  partitions$CHAMPfigure <- ggfig

  return(partitions)
}

###################################

find_max_for_CHAMP <- function(mod_matrix, gammas) {
  boost <- 10^-8

  points_of_change <- c()
  corresponding_partitions <- c()

  gam <- min(gammas)
  while (gam < max(gammas)) {
    spread <- mod_matrix["base"] - gam*mod_matrix["decrement"]
    part <- which(spread==max(spread))[[1]]

    mod_matrix["tilmax"] <- (mod_matrix[part, "base"] - mod_matrix["base"])/
      (mod_matrix[part, "decrement"] - mod_matrix["decrement"])
    mod_matrix[part, "tilmax"] <- NaN
    mod_matrix[which(mod_matrix["tilmax"]<=gam), "tilmax"] <- NaN
    if (all(is.na(mod_matrix["tilmax"]))) { break }

    gam <- min(mod_matrix["tilmax"], na.rm=T) + boost
    points_of_change <- append(points_of_change, gam)
    corresponding_partitions <- append(corresponding_partitions, part)
  }

  return (list("edges"=points_of_change, "partitions"=corresponding_partitions))
}
