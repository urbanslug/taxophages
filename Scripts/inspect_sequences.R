suppressPackageStartupMessages(
  {
    require(ggplot2)
  })

setwd("~/src/Work/UT/")

seq_lengths.l <- read.csv("Data/sequence_lenths.tsv", sep="\t")
seq_lengths.df <- setNames(data.frame(seq_lengths.l),  c("Sample", "Length")) 

### Visualize the structure of the data
ggplot(data=seq_lengths.df, aes(Sample, Sample, fill=Length)) +
  geom_tile() +
  labs(title = "Look at sequence length",
       x = "Sample",
       y = "Length")
