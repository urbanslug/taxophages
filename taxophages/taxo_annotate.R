#!/usr/bin/env Rscript

# Imports ----
suppressPackageStartupMessages(
  {
    require(rsvd)
    require(ape)
    require(ggtree)
    require(ggplot2)
  })

setwd("src/Work/UT/taxophages")

matrix.tsv <- "./Data/covid.qc.sample100.metadata.matrix.csv"
dimensions <- 10
figure <-"./Figures/tree_with_countries.pdf"

# Fetch data ----
# read the data into a dataframe
data.df <- read.delim(matrix.tsv)


# isolate only the coverage data
metadata.df <- data.df[, 1:6]
coverage.df <- data.df[, 7:ncol(data.df)]

# convert the coverage data into a matrix
coverage.matrix <- as.matrix(coverage.df)

# transpose the matrix
coverage.matrix.t <- t(coverage.matrix)

# run rSVD
coverage.rsvd <- rsvd(coverage.matrix.t, k=dimensions)
coverage.rsvd.v <- coverage.rsvd$v
coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)

coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label <- metadata.df$country



# Visualization ----
sample.size <- nrow(data.df)
title <- sprintf("rSVD Tree for %s samples", sample.size)



myPalette <-c("#708090", "#0014a8", "#9f00ff", "#177245", "#f984ef", "#ffae42",
              "#03c03c", "#915f6d", "#f7e98e", "#0070ff", "#663854", "#e8000d",
              "#704214", "#00ced1", "#ffa07a", "#b5651d",  "#918151")

p <- ggtree(coverage.tree) %<+% metadata.df
p +
  geom_tiplab(size=3, aes(color=label)) +
  labs(title=title) +
  scale_color_brewer("country", palette="Spectral")


ggsave(figure, height=10, width=20, dpi=300)
dev.off()



