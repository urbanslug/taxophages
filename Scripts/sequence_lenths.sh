#!/usr/bin/env bash

# Call with the input and output directories e.g ./sequence_lengths.sh <input.fasta> <output.tsv>

INPUT_FASTA="$1"
OUTPUT_TSV="$2"

END=$(wc -l < ${INPUT_FASTA})

for ((i=2;i<=END;i=i+2)); do
    prev=`expr $i - 1`
    # echo "Processing sequence ${prev}"

    char_count=$(sed -n "${i}p" < ${INPUT_FASTA} | wc -c)
    sequence=$(sed -n "${prev}p" < ${INPUT_FASTA})
    ns=$(sed -n "${i}p" < ${INPUT_FASTA} | grep -o \N | wc -w)

    echo -e "${sequence}\t${char_count}\t${ns}" >> ${OUTPUT_TSV}
done
