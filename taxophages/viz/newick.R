#!/usr/bin/env Rscript

if ( Sys.getenv("TAXOPHAGES_ENV")=="server" ) {
  # Handle command line arguments ----
  args = commandArgs(trailingOnly=TRUE)

  matrix.tsv <- args[1]
  newick.tree.path <- args[2]
  metadata.path <- args[3]

  dimensions <- as.integer(args[4])

  # Where packages are
  custom.lib.path <- Sys.getenv("R_PACKAGES")
  .libPaths( c( custom.lib.path, .libPaths()) )
} else {
  setwd("~/src/org/bio-notes/data/ignore")

  matrix.tsv <- "coverage.metadata.tsv"
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
# read the data into a dataframe
message(sprintf("Reading the coverage vector %s", matrix.tsv))
data.df <- read.delim(matrix.tsv)

#filter unknowns
message("Filtering out samples with region unknown.")
data.df.old <- data.df
data.df <- data.df %>% filter(region != "unknown")

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

message("Calculating pairwise distances")
coverage.dist <- dist(coverage.rsvd.v)
coverage.tree <- nj(coverage.dist)

# Metadata ----
message("Preprocessing metadata")
metadata.df <- data.df[, 1:8]

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
extract_short_hash <- function(d) {
  hash <- strsplit(d, "-", fixed = TRUE)[[1]][3]
  substrRight(hash, 8)
}
strain <- sapply(metadata.df$sample, extract_short_hash, USE.NAMES = F)

country <- metadata.df$country
location <- metadata.df$location
date <- metadata.df$date

for (row in 1:length(country)) {
  country <- gsub("People's Republic of China", "China", country, fixed=T)
  location <- gsub("People's Republic of China", "China", location, fixed=T)
  date <- gsub("1970-01-01", "unknown", date, fixed=T)
}

id.df <- data.frame(country, location, strain, date)

# join these into a single string separated by a slash
id.list <- pmap(id.df, paste, sep="/")

replace_underscores <- function(id) {
  str_replace_all(id, " ", "_")
}
id.list.no_space = lapply(id.list, replace_underscores)
id <- unlist(id.list.no_space)

metadata.df <- cbind(strain=id, metadata.df)

# Add url field
url_base <- "http://covid19.genenetwork.org/resource/lugli-4zz18-"
metadata.df$url <- unlist(lapply(metadata.df$path.name, function(x) paste(url_base, x)))

# name tip labels using strain names
coverage.tree$tip.label <- metadata.df$strain

# Write to files ----
message(sprintf("Writing tree to %s", newick.tree.path))
write.tree(coverage.tree, newick.tree.path)

message(sprintf("Writing metadata to %s", metadata.path))
write.table(metadata.df,
            file=metadata.path,
            row.names = F,
            sep='\t',
            quote = FALSE)
