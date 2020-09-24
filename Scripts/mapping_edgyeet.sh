#!/usr/bin/env bash

# set vars
SEQUENCES=data/relabeledSeqs.sorted_by_quality_and_len.fasta
ODGI_GRAPH=data/relabeledSeqs.sorted_by_quality_and_len.g6.unchop.sorted.odgi
OUTPUT_EDGYEET_FASTA=output/first_sequence_edgyeet.gaf

# Build the index
# Very fast index barely a second.
gyeet index -i $ODGI_GRAPH -k 15 -e 3 -t 4

# Isolate the first sequence
sed -n "1p" < $SEQUENCES >> data/first_sequence.fasta
sed -n "2p" < $SEQUENCES >> data/first_sequence.fasta

# Map the first sequence to the graph
gyeet map -i $ODGI_GRAPH -f data/first_sequence.fasta \
      > $OUTPUT_G_FASTA
