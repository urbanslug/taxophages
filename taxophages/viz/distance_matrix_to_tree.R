#!/usr/bin/env Rscript

if ( Sys.getenv("TAXOPHAGES_ENV")=="server" ) {
  # Handle command line arguments ----
  args = commandArgs(trailingOnly=TRUE)
  
  distance_matrix.path <- args[1]
  metadata.path <- args[2]
  newick.tree.path <- args[3]

  # Where packages are
  custom.lib.path <- Sys.getenv("R_PACKAGES")
  .libPaths( c( custom.lib.path, .libPaths()) )
} else {
  setwd("~/src/org/bio-notes/data/ignore")
  

  distance_matrix.path <- "distances.tsv"
  metadata.path <- "metadata"
  newick.tree.path <- "tree.nwk"
}

suppressPackageStartupMessages({
  require(ape)
  })


distance_matrix <- data.frame(read.table(distance_matrix.path))
metadata.df <- read.delim(metadata.path)

f = dist(distance_matrix)
tr <- nj(f)

tr$tip.label <- metadata.df$label

write.tree(tr, newick.tree.path)
plot(tr)
