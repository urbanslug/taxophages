#!/usr/bin/env Rscript

custom.lib.path <- "~/RLibraries"
.libPaths( c( custom.lib.path, .libPaths()) )

# Imports ----
suppressPackageStartupMessages(
  {
    require(ggplot2)
    require(dplyr)
  })

# Command line arguments ----
args = commandArgs(trailingOnly=TRUE)

counts.path <- args[1]
ns.figure.path <- args[2]
coverage.matrix.path <- args[3]
coverage.df.qual.path <- args[4]
threshold <- 0.1

# coverage metadata
message(sprintf("Reading count data: %s", counts.path))
counts.df <- read.delim(counts.path)
message("Finished reading count data")

colnames(counts.df) <- c("name", "sequence.length", "n.count")
counts.df$id <- seq(1, nrow(counts.df)) #not a real id-needed for the plot


ggplot(data=counts.df, aes(x=id)) +
  geom_line(aes(y=sequence.length, color="Length")) +
  geom_line(aes(y=n.count, color="Ns")) +
  labs(title = "Number of Ns in each sample",
       color='',
       x = "Sample",
       y = "Length") 

message(sprintf("Generating plot: %s", ns.figure.path))
ggsave(ns.figure.path, height=10, width=20, dpi=300)
dev.off()


# Filter for samples with > 0.1% Ns
filtered.df <- filter(counts.df, n.count/sequence.length * 100 <= threshold)
filtered.names.df <- filtered.df$name
filtered.names <- as.vector(unlist(lapply(filtered.names.df, function(x) {(strsplit(x, ">"))[[1]][2]})))

# read coverage matrix
message(sprintf("Reading coverage matrix: %s", coverage.matrix.path))
coverage.df <- read.delim(coverage.matrix.path)
message("Finished coverage matrix")

message(sprintf("Filtering for N count >%s", threshold))
coverage.df.qual <- filter(coverage.df, path.name %in% filtered.names)

message(sprintf("Saving quality checked coverage matrix to %s", coverage.df.qual.path))
write.csv(coverage.df.qual, coverage.df.qual.path, row.names = TRUE)
