#!/usr/bin/env Rscript

if ( Sys.getenv("TAXOPHAGES_ENV")=="server" ) {
  # Handle command line arguments ----
  args = commandArgs(trailingOnly=TRUE)

  matrix.tsv <- args[1]

  recuded.matrix.path <- args[2]
  metadata.path <- args[3]
  newick.tree.path <- args[4]

  dimensions <- as.integer(args[5])
  filter_unknowns <- args[6]

  # handle args
  filter_unknowns <- tolower(filter_unknowns)

  # Where packages are
  custom.lib.path <- Sys.getenv("R_PACKAGES")
  .libPaths( c( custom.lib.path, .libPaths()) )
} else {
  setwd("~/src/Work/UT/experiments/data/covid/")

  matrix.tsv <- "sample.100.metadata.tsv"
  recuded.matrix.path <- "../../trees/covid/sample_reduced_100.tsv"
  metadata.path <- "../../trees/covid/sample_metadata_100.tsv"
  newick.tree.path <- "../../trees/covid/sample_100_tree.nwk"

  dimensions <- 10
  filter_unknowns <- "true"
}

# Imports ----
suppressPackageStartupMessages(
  {
    require(ape)
    require(xml2)
    require(rsvd)
    require(purrr)
    require(dplyr)
    require(ggtree)
    require(ggplot2)
    require(svglite)
    require(tidyverse)
    require(svgPanZoom)
  })

# Read data ----
message(sprintf("Reading matrix %s", matrix.tsv))
# read the data into a dataframe
data.df <- read.delim(matrix.tsv)
message("Successfully read matrix")

#filter unknowns
if ( filter_unknowns=="true" ) {
  message("Filtering out samples with region unknown.")
  data.df.old <- data.df
  data.df <- data.df %>% filter(region != "unknown")
}

# Preprocess ----
message("Preprocessing the coverge matrix")

# isolate only the coverage data
coverage.df <- data.df[, 9:ncol(data.df)]

# convert the coverage data into a matrix
coverage.matrix <- as.matrix(coverage.df)

# transpose the matrix
coverage.matrix.t <- t(coverage.matrix)

# rSVD ----
message(sprintf("Approximating coverge matrix down to %s dimensions", dimensions))
coverage.rsvd <- rsvd(coverage.matrix.t, k=dimensions)
coverage.rsvd.v <- coverage.rsvd$v

message(sprintf("Saving reduced matrix to %s", recuded.matrix.path))
coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)
write.table(coverage.rsvd.v.df, recuded.matrix.path, sep="\t", row.names = TRUE)

message("Calculating pairwise distances")
coverage.dist <- dist(coverage.rsvd.v)
coverage.tree <- nj(coverage.dist)

# Metadata ----
message("Preprocessing metadata")

extract_short_hash <- function(d) {
  hash <- strsplit(d, "-", fixed = TRUE)[[1]][3]
  substr(hash, 1,6)
}
strain <- sapply(data.df$sample, extract_short_hash, USE.NAMES = F)

metadata.df <- cbind(strain=strain, data.df[, 1:8])

# rename path.name to url
names(metadata.df)[names(metadata.df) == 'path.name'] <- 'url'

# name tip labels using strain names
coverage.tree$tip.label <- metadata.df$strain

# Write to files ----
message(sprintf("Writing tree to %s", newick.tree.path))
write.tree(coverage.tree, newick.tree.path)

message(sprintf("Writing metadata to %s", metadata.path))
write.table(metadata.df, file=metadata.path, row.names = F, sep='\t', quote = FALSE)
