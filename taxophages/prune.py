#!/usr/bin/env python
import os
import re

import csv
import click
from random import randint
import subprocess

from .io import read_document, write_txt

def prune(distance_matrix_tsv_filepath, metadata_tsv_filepath, pruned_metadata_tsv_filepath, neighbor_tsv_filepath):
    click.echo("Reading %s" % distance_matrix_tsv_filepath)
    distance_matrix = read_document(distance_matrix_tsv_filepath)
    pruned =  set()
    neighbors = []

    distances = distance_matrix[1:]
    click.echo("Pruning a distance matrix containing %d samples" % len(distances))
    # skip the first row which is are column labels
    with click.progressbar(distances) as rows:
        for idx, row in enumerate(rows):
            if idx in pruned:
                continue

            # tuple of col, value
            # expect first to be the least
            least = (0, float('inf'))

            # look through the rows
            for col, val in enumerate(row):
                current = float(val)

                if (current != 0 and (not col in pruned) and (current < least[1])):
                    least = (col, current)

            pruned.add(least[0])
            neighbors.append((idx, least[0]))

    click.echo("Pruned %d samples" % len(pruned))

    click.echo("Reading %s" % metadata_tsv_filepath)
    metadata = read_document(metadata_tsv_filepath)

    click.echo("Generating pruned coverage matrix")
    picked = []
    picked.append("\t".join(metadata[0]) + "\n")

    for i, row in enumerate(metadata[1:]):
        if i in pruned:
            continue

        picked.append("\t".join(row) + "\n")

    picked_count = len(picked) - 1
    click.echo("Writing %d samples into %s" % (picked_count, pruned_metadata_tsv_filepath))
    write_txt(picked, pruned_metadata_tsv_filepath)


    click.echo("Writing neighbors into %s" % neighbor_tsv_filepath)
    tsv_line = "{}\t{}\n"
    field_names = tsv_line.format("sample", "neighbor")
    neighbor_tabbed_data = [field_names]

    for (sample, neighbor) in neighbors:
        line = tsv_line.format(metadata[sample+1][0], metadata[neighbor+1][0])
        neighbor_tabbed_data.append(line)

    write_txt(neighbor_tabbed_data, neighbor_tsv_filepath)
