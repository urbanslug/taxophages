#!/usr/bin/env Rscript

custom.lib.path <- "~/RLibraries"
.libPaths( c( custom.lib.path, .libPaths()) )

# Imports ----
suppressPackageStartupMessages({
  require(ape)
  require(xml2)
  require(rsvd)
  require(purrr)
  require(dplyr) 
  require(ggtree)
  require(ggplot2)
  require(tidyverse)
  require(svglite)
  require(htmlwidgets)
  require(svgPanZoom)
})

# Command line arguments ----
args = commandArgs(trailingOnly=TRUE)

figure <- args[1]

# Zoom ----
dir <- getwd()
xml <- read_xml(figure)
xml_attr(xml, "viewBox") <- "0 0 1500 20000"

html_figure <- paste(dir, "testy.html", sep="/")
message(sprintf("Wrap HTML for %s", html_figure))

html_widget <- svgPanZoom(
  xml,
  height="100%",
  width="100%",
  controlIconsEnabled=TRUE
  )

saveWidget(html_widget, html_figure)
