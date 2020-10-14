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
recuded.matrix.path <- args[3]
dimensions <- 100

if ( length(args) > 3 ) {
  dimensions <- as.integer(args[4])
}


# Fetch data ----
message(sprintf("Reading matrix %s", matrix.tsv))
# read the data into a dataframe
data.df <- read.delim(matrix.tsv, sep=",")
message("Successfully read matrix")

# isolate only the coverage data
coverage.df <- data.df[, 4:ncol(data.df)]

# convert the coverage data into a matrix
coverage.matrix <- as.matrix(coverage.df)

# transpose the matrix
coverage.matrix.t <- t(coverage.matrix)

# run rSVD
message(sprintf("Approximating coverge matrix down to %s dimensions", dimensions))
coverage.rsvd <- rsvd(coverage.matrix.t, k=dimensions)
coverage.rsvd.v <- coverage.rsvd$v
coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)


# message(sprintf("Saving reduced matrix to %s", recuded.matrix.path))
#write.csv(coverage.rsvd.v.df, recuded.matrix.path, row.names = TRUE)

coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label = data.df$X

# Visualization ----
sample.size <- nrow(data.df)
title <- sprintf("rSVD Tree for %s samples", sample.size)
message(sprintf("Generating rSVD tree: %s", figure))
ggtree(coverage.tree) + geom_tiplab(size=3) + labs(title=title)
ggsave(figure, height=50, width=42, dpi=300, limitsize = FALSE)
dev.off()

message("Done")