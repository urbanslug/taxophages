#!/usr/bin/env bash

# set vars
SEQUENCE=data/downloaded/first.fasta
INPUT_GRAPH=data/dozyg_data/relabeledSeqs.sorted_by_quality_and_len.g6.unchop.sorted.odgi
OUTPUT_DOZYG=output/first_sequence_dozyg.gaf

# Build the index
# Very fast index barely a second.
echo "Indexing ${INPUT_GRAPH}"
dozyg index -i $INPUT_GRAPH -k 15 -e 3 -t 4

# Map the first sequence to the graph
echo "Mapping ${SEQUENCE} to ${INPUT_GRAPH}"
dozyg map -g 1 -i $INPUT_GRAPH -f $SEQUENCE > $OUTPUT_DOZYG

echo "Output ${OUTPUT_DOZYG}"
