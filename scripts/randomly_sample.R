#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

matrix.tsv <- args[1]
recuded.matrix.path <- args[2]
sample_size <- args[3]


message(sprintf("Reading the large matrix %s", matrix.tsv))
data.df <- read.delim(matrix.tsv, sep=",")

message(sprintf("Extracting %s random samples.", sample_size))
samples.df <- data.df[sample(nrow(data.df), sample_size), ]

message(sprintf("Writing reduced matrix to %s", recuded.matrix.path))
write.csv(samples.df, recuded.matrix.path, row.names = TRUE)

message("Done")