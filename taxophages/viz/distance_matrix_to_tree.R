#!/usr/bin/env Rscript

if ( Sys.getenv("TAXOPHAGES_ENV")=="server" ) {
  # Handle command line arguments ----
  args = commandArgs(trailingOnly=TRUE)
  
  distance_matrix.path <- args[1]
  metadata.path <- args[2]
  newick.tree.path <- args[3]
  figure.path <- args[4]
  figure.x <-  as.integer(args[5])
  figure.y <- as.integer(args[6])

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
  require(ggtree)
  require(ggplot2)
  })


distance_matrix <- data.frame(read.table(distance_matrix.path))
metadata.df <- read.delim(metadata.path)

distance_matrix.dist <- dist(distance_matrix)
tr <- nj(distance_matrix.dist)

# insert labels
tr$tip.label <- metadata.df$label

message(sprintf("Saving newick tree to: %s", newick.tree.path))
write.tree(tr, newick.tree.path)

message(sprintf("Saving cladogram to: %s", figure.path))
ggtree(tr) + geom_tiplab(size=0.5)
ggsave(figure.path,
       units="cm",
       height=figure.y,
       width=figure.x,
       dpi=150,
       limitsize=FALSE)
dev.off()
