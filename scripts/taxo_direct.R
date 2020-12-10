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
sample_size <- 100

if ( length(args) > 2 ) {
  sample_size <- as.integer(args[3])
}


# Fetch data ----
message(sprintf("Reading %s", matrix.tsv))
# read the data into a dataframe
data.df <- read.delim(matrix.tsv)
message(sprintf("Successfully read %s", matrix.tsv))

# isolate only the coverage data
coverage.df <- data.df[, 4:ncol(data.df)]
sampled.df <- data.df[sample(nrow(data.df), sample_size), ]

# convert the coverage data into a matrix
coverage.matrix <- as.matrix(sampled.df)

message("Calculating pairwise distances")
coverage.dist <- dist(coverage.matrix)
coverage.tree <- nj(coverage.dist)



# newick.tree.path <- "./svd_tree.nwk"
# message(sprintf("Saving newick tree to %s", newick.tree.path))
# write.tree(coverage.tree, newick.tree.path)

# Visualization ----
message(sprintf("Generating tree: %s", figure))
p <- ggtree(coverage.tree)
p +
  geom_tiplab(size=4) +
  geom_tippoint(size=2) +
  labs(title = "Direct Neighbour Joining from Eucledian Distance") +

ggsave(paste(figure, sep=""),
       height=500,
       width=22,
       dpi=300)
dev.off()

message("Done")