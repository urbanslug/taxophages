#!/usr/bin/env Rscript

custom.lib.path <- "~/RLibraries"
.libPaths( c( custom.lib.path, .libPaths()) )

# Imports ----
suppressPackageStartupMessages(
  {
    require(rsvd)
    require(ape)
    require(ggtree)
    require(ggplot2)
  })

# Command line arguments ----
args = commandArgs(trailingOnly=TRUE)

matrix.tsv <- args[1]
figure <- args[2]
tree.nwk.path <- args[3]

message(sprintf("Reading matrix %s", matrix.tsv))
coverage.rsvd.v.df <- read.delim(matrix.tsv, sep=",")

message("Computing pairwise distances")
coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)
# coverage.tree$tip.label = data.df$X


# message(sprintf("Saving newick tree to %s", tree.nwk.path))
# write.tree(coverage.tree, tree.nwk.path)

# Visualization ----
sample.size <- nrow(coverage.rsvd.v.df)
title <- sprintf("rSVD Tree for %s samples", sample.size)
message(sprintf("Generating rSVD tree: %s", figure))
ggtree(coverage.tree) + geom_tiplab(size=3) + labs(title=title)
ggsave(figure, height=200, width=50, dpi=150, limitsize = FALSE)
dev.off()