#!/usr/bin/env bash

# Given a file with sequence id's probably from grepping isolate the IDs
input=$1
output=$2

for seq in $input;
do
    id=$(sed -n 's/.*=\(.*\)\/[a-z.]*/\1/p' < ${seq})
    echo -e "${id}" >> ${output}
done
