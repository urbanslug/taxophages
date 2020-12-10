#!/usr/bin/env Rscript

custom.lib.path <- "~/RLibraries"
.libPaths( c( custom.lib.path, .libPaths()) )

# Imports ----
suppressPackageStartupMessages(
  {
    require(ape)
    require(ggtree)
    require(ggplot2)
  })

args = commandArgs(trailingOnly=TRUE)

matrix.csv <- args[1]
figure <- args[2]
sample_size  <- 100

if ( length(args) > 2 ) {
  sample_size  <- as.integer(args[3])
}

message(sprintf("Reading reduced matrix: %s", matrix.csv))
data.df <- read.delim(matrix.csv, sep=",")

sampled.df <- data.df[sample(nrow(data.df), sample_size), ]

message("Calculating pairwise distances")
coverage.dist <- dist(sampled.df)
coverage.tree <- nj(coverage.dist)
#coverage.tree$tip.label = data.df$path.name

# newick.tree.path <- "./svd_tree.nwk"
# message(sprintf("Saving newick tree to %s", newick.tree.path))
# write.tree(coverage.tree, newick.tree.path)

# Visualization ----
message(sprintf("Generating tree: %s", figure))
ggtree(coverage.tree)
ggsave(figure, height=10, width=22, dpi=300)
dev.off()

message("Done")
