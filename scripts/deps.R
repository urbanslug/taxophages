#!/usr/bin/env Rscript

# Run with R_PACKAGES="~/RLibraries" ./deps.R

# Install deps in ~/RLibraries  ----
custom.lib.path <- Sys.getenv("R_PACKAGES")
# use insecure mirror
mirror <- "http://mirrors.nics.utk.edu/cran/"
.libPaths( c(custom.lib.path, .libPaths()) )

list.of.packages <- c("rsvd", "ape", "ggplot2", "R.utils",
                      # ggtree deps
                      "aplot", "dplyr", "purrr", "rvcheck",
                      "tidyr", "tidytree", "jsonlite" )

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {
  install.packages(new.packages, lib = custom.lib.path, repos = mirror)
}


mirror.bioc <- "http://bioconductor.org/packages/3.11/bioc/"
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", lib = custom.lib.path, repos = mirror)

BiocManager::install("ggtree", lib = custom.lib.path, site_repository = mirror.bioc)