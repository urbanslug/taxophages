#!/usr/bin/env Rscript

if ( Sys.getenv("TAXOPHAGES_ENV")=="server" ) {
  # Handle command line arguments ----
  args = commandArgs(trailingOnly=TRUE)
  
  distance_matrix.path <- args[1]
  metadata.path <- args[2]
  newick.tree.path <- args[3]
  figure.path <- args[4]
  figure.x <-  as.integer(args[5])
  figure.y <- as.integer(args[6])

  # Where packages are
  custom.lib.path <- Sys.getenv("R_PACKAGES")
  .libPaths( c( custom.lib.path, .libPaths()) )
} else {
  setwd("~/src/org/bio-notes/data/ignore")
  

  distance_matrix.path <- "distances.tsv"
  metadata.path <- "metadata"
  newick.tree.path <- "tree.nwk"
}

suppressPackageStartupMessages({
  require(ape)
  require(ggtree)
  require(ggplot2)
  })


distance_matrix <- data.frame(read.table(distance_matrix.path))
metadata.df <- read.delim(metadata.path)

distance_matrix.dist <- dist(distance_matrix)
tr <- nj(distance_matrix.dist)

# insert labels
tr$tip.label <- metadata.df$label

message(sprintf("Saving newick tree to: %s", newick.tree.path))
write.tree(tr, newick.tree.path)

grouping.field <- "region"
gf <- metadata.df[[grouping.field]]
unique.countries <- unique(gf)
unique.countries.count <- length(unique.countries)

sample.size <- nrow(metadata.df)
plot.title <- sprintf("Mash Tree for %s Samples", sample.size)
legend.title <- grouping.field
layout <- "rectangular"

phage.colors <- c("#000000", "#708090", "#0014a8", "#9f00ff", "#177245",
                  "#f984ef", "#ffae42", "#03c03c", "#915f6d", "#f7e98e",
                  "#0070ff", "#663854", "#e8000d", "#704214", "#00ced1",
                  "#ffa07a", "#b5651d",  "#918151")

message("Generating cladogram")
plot <- ggtree(tr, layout=layout, size=0.1, aes(color=region)) %<+% metadata.df
plot +
  geom_tippoint(size=0.01, aes(color=region), show.legend=FALSE) +
  geom_tiplab(size=0.5, aes(color="#000000"), show.legend=FALSE) +
  labs(title=plot.title) +
  scale_colour_manual(
    breaks=unique.countries,
    na.translate=TRUE,
    na.value="#cccccc",
    name=legend.title,
    values=phage.colors)

message(sprintf("Saving cladogram to: %s", figure.path))
ggsave(figure.path,
       units="cm",
       height=figure.y,
       width=figure.x,
       dpi=150,
       limitsize=FALSE)
dev.off()