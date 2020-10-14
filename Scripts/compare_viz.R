#!/usr/bin/env Rscript

custom.lib.path <- "~/RLibraries"
.libPaths( c( custom.lib.path, .libPaths()) )

# Imports ----
suppressPackageStartupMessages(
  {
    require(ape)
    require(rsvd)
    require(ggtree)
    require(ggplot2)
  })

args = commandArgs(trailingOnly=TRUE)

matrix.csv <- args[1]
figure.path.direct <- args[2]
figure.path.rsvd <- args[3]
dimensions <- 10

if ( length(args) > 3 ) {
  dimensions <- as.integer(args[4])
}

message(sprintf("Reading matrix: %s", matrix.csv))
data.df <- read.delim(matrix.csv, sep=",")

# isolate only the coverage data
coverage.df <- data.df[, 4:ncol(data.df)]

# Direct ----
message("Calculating direct pairwise distances")
coverage.dist <- dist(coverage.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label = data.df$X

## Visualization ----
message(sprintf("Generating direct tree: %s", figure.path.direct))
ggtree(coverage.tree) + geom_tiplab(size=3)
ggsave(figure.path.direct, height=20, width=22, dpi=300)
dev.off()

# SVD ----
# convert the coverage data into a matrix
coverage.matrix <- as.matrix(coverage.df)

# transpose the matrix
coverage.matrix.t <- t(coverage.matrix)

# run rSVD
message(sprintf("Approximating coverge matrix down to %s dimensions", dimensions))
coverage.rsvd <- rsvd(coverage.matrix.t, k=dimensions)
coverage.rsvd.v <- coverage.rsvd$v
coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)

coverage.rsvd.dist <- dist(coverage.rsvd.v.df)
coverage.rsvd.tree <- nj(coverage.rsvd.dist)
coverage.rsvd.tree$tip.label = data.df$X


# Visualization ----
message(sprintf("Generating rSVD tree: %s", figure.path.rsvd))
ggtree(coverage.rsvd.tree) + geom_tiplab(size=3)
ggsave(figure.path.rsvd, height=20, width=22, dpi=300)
dev.off()

message("Done")
