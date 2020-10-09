#!/usr/bin/env Rscript


# Install deps in ~/RLibraries  ----
custom.lib.path <-"~/RLibraries"
# use insecure mirror
mirror <- "http://mirrors.nics.utk.edu/cran/"
.libPaths( c( custom.lib.path, .libPaths() ) )

list.of.packages <- c("rsvd", "ape", "ggplot2",
                      # ggtree deps
                      "aplot", "dplyr", "purrr", "rvcheck",
                      "tidyr", "tidytree", "jsonlite" )
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages,
                                          lib = custom.lib.path,
                                          repos = mirror)

mirror.bioc <- "http://bioconductor.org/packages/3.11/bioc/"
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", lib = custom.lib.path, repos = mirror)

BiocManager::install("ggtree",
                     lib = custom.lib.path,
                     site_repository = mirror.bioc)

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

message("Successfully read data")

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
coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label = data.df$path.name

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