#!/usr/bin/env Rscript

custom.lib.path <-"~/RLibraries"
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
dimensions <- 2

if ( length(args) > 2 ) {
  dimensions <- as.integer(args[3])
}


# Fetch data ----
message("Reading data")
# read the data into a dataframe
data.df <- read.delim(matrix.tsv)

message(sprintf("Successfully read %s", matrix.tsv))

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

recuded.matrix.path <-  "./reduced.csv"
message(sprintf("Saving reduced matrix to %s", recuded.matrix.path))
write.csv(coverage.rsvd.v, recuded.matrix.path, row.names = TRUE)

coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)
coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label = data.df$path.name


newick.tree.path <- "./svd_tree.nwk"
message(sprintf("Saving newick tree to %s", newick.tree.path))
write.tree(coverage.tree, newick.tree.path)

# Visualization ----
message("Creating tree")
p <- ggtree(coverage.tree)
p +
  geom_tiplab(size=4) +
  geom_tippoint(size=2, aes(color=label)) +
  labs(title = "SVD Tree", color="Samples") +
  theme_tree(legend.position='right')

ggsave(paste(figure, sep=""),
       height=10,
       width=22,
       dpi=300)
dev.off()

message("Done")