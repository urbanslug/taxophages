#!/usr/bin/env Rscript

# Reads a coverage table and metadata and writes to Newick
# Also validates the metadata

if ( Sys.getenv("TAXOPHAGES_ENV")=="server" ) {
  # Handle command line arguments ----
  args = commandArgs(trailingOnly=TRUE)

  newick.tree.path <- args[1]
  metadata.path <- args[2]

  newick.tree.path.updated <- args[3]
  metadata.path.updated <- args[4]
  # Where packages are
  custom.lib.path <- Sys.getenv("R_PACKAGES")
  .libPaths( c( custom.lib.path, .libPaths()) )
} else {
  setwd("~/src/Work/UT/experiments/trees/covid/25k")

  newick.tree.path <- "25k.nwk"
  metadata.path <- "metadata.25k.tsv"

  newick.tree.path.updated <- "25k.updated.nwk"
  metadata.path.updated <- "metadata.25k.updated.tsv"
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

# Tree ----
data.tree <- ape::read.tree(file=newick.tree.path)

# Metadata ----
metadata.df <- read.delim(metadata.path)


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

for (row in 1:length(country)) {
  country <- gsub("People's Republic of China", "China", country, fixed=T)
  location <- gsub("People's Republic of China", "China", location, fixed=T)
}

id.df <- data.frame(country, location, strain, metadata.df$date)

# join these into a single string
id.list <- pmap(id.df, paste, sep="/")

replace_underscores <- function(id) {
  str_replace_all(id, " ", "_")
}
id.list.no_space = lapply(id.list, replace_underscores)
id <- unlist(id.list.no_space)

metadata.df.id <- cbind(id=id, metadata.df)

tip_labels <- data.tree$tip.label

# update tip labels
for (row in 1:nrow(metadata.df.id)) {
  strain.loop <- metadata.df.id[row, "strain"]
  id.loop <- metadata.df.id[row, "id"]
  tip_labels <- sub(strain.loop, id.loop, tip_labels, fixed=T)
}

data.tree$tip.label <- tip_labels

names(metadata.df.id)[names(metadata.df.id) == 'strain'] <- 'short.hash'
names(metadata.df.id)[names(metadata.df.id) == 'id'] <- 'strain'


# Write to files ----
message(sprintf("Writing updated tree to %s", newick.tree.path.updated))
write.tree(data.tree, newick.tree.path.updated)

message(sprintf("Writing updated metadata to %s", metadata.path.updated))
write.table(metadata.df.id,
            file=metadata.path.updated,
            row.names = F,
            sep='\t',
            quote = FALSE)