#!/usr/bin/env bash

# Call with the input and output directories e.g ./sequence_lengths.sh <input.fasta> <output.txt>

INPUT_FASTA="$1"
OUTPUT_TSV="$2"

END=$(wc -l < ${INPUT_FASTA})

for ((i=2;i<=END;i=i+2)); do
    prev=`expr $i - 1`
    # echo "Processing sequence ${prev}"

    char_count=$(sed -n "${i}p" < ${INPUT_FASTA} | wc -c)
    sequence=$(sed -n "${prev}p" < ${INPUT_FASTA})

    echo -e "${sequence} \t ${char_count}" >> ${OUTPUT_TSV}
done
