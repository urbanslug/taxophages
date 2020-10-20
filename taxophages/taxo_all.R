#!/usr/bin/env Rscript

custom.lib.path <- "~/RLibraries"
.libPaths( c( custom.lib.path, .libPaths()) )

# Imports ----
suppressPackageStartupMessages({
    require(rsvd)
    require(ape)
    require(ggtree)
    require(ggplot2)
  })

# Command line arguments ----
args = commandArgs(trailingOnly=TRUE)

if (length(args) < 2) {
  stop("Not enough arguments passed to taxo_RSVD
       First should be a tsv matrix and the second should be the output png.
       third optional arument is the number of dimensions to reduce to
       For example:
        ./taxo_rSVD path/to/input.tsv path/to/output.png 3\n\n", call.=FALSE)
}

matrix.tsv <- args[1]
recuded.matrix.path <- args[2]
figure <- args[3]
dimensions <- as.integer(args[4])

# Fetch data ----
message(sprintf("Reading matrix %s", matrix.tsv))
# read the data into a dataframe
data.df <- read.delim(matrix.tsv)
message("Successfully read matrix")

# isolate only the coverage data
coverage.df <- data.df[, 7:ncol(data.df)]
metadata.df <- cbind(id = 1:nrow(data.df), data.df[, 1:6])

grouping.field <- "date"
gf <- metadata.df[[grouping.field]]
unique.countries <- unique(gf)
unique.countries.count <- length(unique.countries)

# convert the coverage data into a matrix
coverage.matrix <- as.matrix(coverage.df)

# transpose the matrix
coverage.matrix.t <- t(coverage.matrix)

# run rSVD
message(sprintf("Approximating coverge matrix down to %s dimensions", dimensions))
coverage.rsvd <- rsvd(coverage.matrix.t, k=dimensions)
coverage.rsvd.v <- coverage.rsvd$v
coverage.rsvd.v.df <- data.frame(coverage.rsvd.v)

message(sprintf("Saving reduced matrix to %s", recuded.matrix.path))
write.table(coverage.rsvd.v.df, recuded.matrix.path, sep="\t", row.names = TRUE)

message("Calculating pairwise distances")
coverage.dist <- dist(coverage.rsvd.v.df)
coverage.tree <- nj(coverage.dist)

# Visualization ----
message("Generating rSVD tree")

sample.size <- nrow(data.df)
plot.title <- sprintf("rSVD Tree for %s samples", sample.size)
legend.title <- grouping.field


myPalette <-c("#708090", "#0014a8", "#9f00ff", "#177245", "#f984ef", "#ffae42",
              "#03c03c", "#915f6d", "#f7e98e", "#0070ff", "#663854", "#e8000d",
              "#704214", "#00ced1", "#ffa07a", "#b5651d",  "#918151")
colfunc <- colorRampPalette(myPalette)
phage.colors <- c(colfunc(10),
                  rainbow(unique.countries.count)[3:unique.countries.count])

p <- ggtree(coverage.tree, size=0.1, aes(color=date)) %<+% metadata.df
p +
  geom_tippoint(size=0.1, aes(color=date), show.legend=FALSE) +
  labs(title=plot.title) +
  scale_colour_manual(
    breaks=unique.countries,
    na.translate=TRUE,
    na.value="#cccccc",
    name=legend.title,
    values=phage.colors
  )

message(sprintf("Saving rSVD tree to %s", figure))
ggsave(figure, units="cm", dpi=300, height=400, width=40, limitsize=FALSE)
dev.off()
