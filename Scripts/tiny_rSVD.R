#!/usr/bin/env Rscript

# Imports ----
suppressPackageStartupMessages(
  {
    require(rsvd)
  })


setwd("~/src/Work/UT/taxophages/")

# read the data into a dataframe
data.df <- read.delim("Data/DRB1-3123_matrix.tsv")

# number of samples
sample_count <- nrow(coverage.df)

# isolate only the coverage data
coverage.df <- data.df[,4:ncol(data.df)]

# convert the coverage data into a matrix
coverage.matrix <- as.matrix(coverage.df)

# run rSVD
coverage.rsvd <- rsvd(coverage.matrix)

# transpose the matrix
# -----

# run rSVD on the transposed matrix; gives us a 12x12 v matrix.
coverage.matrix.t <- t(coverage.matrix)
coverage.rsvd.t <- rsvd(coverage.matrix.t)
