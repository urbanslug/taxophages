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

if (length(args) < 2) {
  stop("Not enough arguments passed to taxo_RSVD
       First should be a tsv matrix and the second should be the output png.
       third optional arument is the number of dimensions to reduce to
       For example:
        ./taxo_rSVD path/to/input.tsv path/to/output.png 3\n\n", call.=FALSE)
}

matrix.tsv <- args[1]
figure <- args[2]


# Fetch data ----
message(sprintf("Reading matrix %s", matrix.tsv))
# read the data into a dataframe
data.df <- read.delim(matrix.tsv)
message("Successfully read matrix")

coverage.dist <- dist(data.df)
coverage.tree <- nj(coverage.dist)


# Visualization ----
message(sprintf("Generating rSVD tree"))

sample.size <- nrow(data.df)
title <- sprintf("rSVD Tree for %s samples", sample.size)
ggtree(coverage.tree) + geom_tiplab(size=3) + labs(title=title)

message(sprintf("Saving rSVD tree to: %s", figure))
ggsave(figure, height=10, width=20, dpi=150)
dev.off()