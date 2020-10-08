#!/usr/bin/env Rscript

# Imports ----
suppressPackageStartupMessages(
  {
    require(rsvd)
    require(ape)
    require(ggtree)
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

# transpose the matrix
coverage.matrix.t <- t(coverage.matrix)

# run rSVD
coverage.rsvd <- rsvd(coverage.matrix.t, k=2)
coverage.rsvd.v <- coverage.rsvd$v

coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)
coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label = data.df$path.name


p <- ggtree(coverage.tree)
p +
  geom_tiplab(size=4) +
  geom_tippoint(size=2, aes(color=label)) +
  labs(title = "SVD Tree", color="Samples") +
  theme_tree(legend.position='right')

ggsave(paste("./Figures/", "SVD_Tree.png", sep=""),
       height=10,
       width=22,
       dpi=300)
dev.off()
