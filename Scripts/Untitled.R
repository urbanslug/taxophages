setwd("~/src/Work/UT/taxophages/")

matrix.csv <- "Data/reduced.csv"
figure <- "Figures/SVD_sampled.png"

data.df <- read.delim(matrix.csv, sep=",")

coverage.dist <- dist(data.df)
coverage.tree <- nj(coverage.dist)
coverage.tree$tip.label = data.df$path.name


# newick.tree.path <- "./svd_tree.nwk"
# message(sprintf("Saving newick tree to %s", newick.tree.path))
# write.tree(coverage.tree, newick.tree.path)

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
