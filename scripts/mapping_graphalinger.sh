#!/usr/bin/env bash

# Set vars
SEQUENCES=data/relabeledSeqs.sorted_by_quality_and_len.fasta
COVID_GFA_UNCHOPPED=data/relabeledSeqs.sorted_by_quality_and_len.g6.gfa
OUTPUT_GA_FASTA=output/first_sequence_graphaligner.gaf
COVID_GFA_CHOPPED=data/relabeledSeqs.sorted_by_quality_and_len.g6.unchop.gfa

# Map the first sequence to the graph
# GraphAligner -g $COVID_GFA_UNCHOPPED -f $SEQUENCES -a $OUTPUT_GA_FASTA

# Map the first sequence to the graph
# Let's go with 4 threads
GraphAligner -t 4 -g $COVID_GFA_CHOPPED -f $SEQUENCES -a $OUTPUT_GA_FASTA
