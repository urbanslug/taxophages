#!/usr/bin/env Rscript

# Imports ----
suppressPackageStartupMessages(
  {
    require(dplyr)
    require(FactoMineR)
    require(ggplot2)
    require(ggtree)
    require(rsvd)
    require(FactoMineR)
    require(pracma)
    require(ape)
  })


setwd("~/src/Work/UT/taxophages/")

data.df <- read.delim("Data/DRB1-3123_matrix.tsv")

# 
coverage.df <- data.df[,4:ncol(data.df)]
coverage.matrix <- as.matrix(coverage.df)
sample_count = nrow(coverage.df)

coverage.rsvd <- rsvd(coverage.matrix, k=sample_count)
