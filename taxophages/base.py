#!/usr/bin/env python
import os

import csv
import click
from random import randint
import subprocess

from .io import file_len, write_document, read_document, write_txt, read_txt
from .utils import isolate_field

def isolate_fields(input_csv, field_name, txt_path):
    rows = read_document(input_csv)

    field_names = rows[0]
    data = rows[1:]

    field = isolate_field(field_names, data, field_name)
    write_txt(field, txt_path, insert_newlines=True)

# Loop through sequences files in a fasta file and count the distribution of bases
def base_count(fasta_path, csv_path):
    sequence_names = []
    lengths = []
    n_count= []

    with open(fasta_path) as f:
        for idx, line in enumerate(f):
            if idx % 2 == 0:
                sequence_names.append(line.strip())
            else:
                lengths.append(len(line))
                n_count.append(line.count("N"))

    click.echo("Aggregating data")
    entries = map(lambda name, length, ns:({"sequence_name": name, "length": length, "n_count": ns}),
                  sequence_names, lengths, n_count)
    field_names = ['sequence_name', 'length', 'n_count']

    click.echo("Writing tab separated csv to %s" % csv_path)
    write_document(csv_path, field_names, entries)


# Do some QC shit
def filter_threshold(csv_path, txt_path, threshold):
    click.echo('Reading %s' % csv_path)
    rows = read_document(csv_path)[1:]
    result = []

    click.echo("Filtering")
    for row in rows:
        seq = row[0]
        lenth = row[1]
        n = row[2]

        if ((int(n)/int(lenth)*100) <= float(threshold)):
            # drop the greater than sign & add a newline after
            result.append("%s\n" % seq[1:])

    click.echo("Writing sequences to %s" % txt_path)
    write_txt(result, txt_path)


def filter_matrix(csv_path, filtered_matrix, txt_path):
    click.echo('Reading %s' % txt_path)
    filter_sequences = read_txt(txt_path)
    stripped = list(map(lambda x: x.strip(), filter_sequences))

    click.echo('Reading %s' % csv_path)
    rows = read_document(csv_path)

    entries = []
    field_names = "\t".join(rows[0]) + "\n"
    entries.append(field_names)

    try:
        #iter(rows)
        click.echo("Filtering")
        for row in rows:
            if row and row[0].strip() in stripped:
                j = "\t".join(row) + "\n"
                entries.append(j)
    except TypeError:
        print('Unable to iterate over coverage matrix')
        exit(1)

    click.echo("Writing coverage matrix to %s" % filtered_matrix)
    write_txt(entries, filtered_matrix)


def sample_matrix(size, csv_path, sampled_csv_path):
    click.echo('Reading %s' % csv_path)
    rows = read_document(csv_path)
    max_index = len(rows) - 1

    entries = []
    field_names = "\t".join(rows[0]) + "\n"
    entries.append(field_names)

    click.echo('Selecting %s samples' % size)
    for _ in range(size):
        random_index = randint(1, max_index)
        random_row = rows[random_index]
        j = "\t".join(random_row) + "\n"
        entries.append(j)

    click.echo("Writing subsampled matrix to %s" % sampled_csv_path)
    write_txt(entries, sampled_csv_path)


def taxo_rsvd(csv_file_path, reduced_csv_file_path, dimensions):
    click.echo("Calling taxo_rSVD.R")
    subprocess.call (
        f"./taxophages/viz/taxo_rSVD.R {csv_file_path} {reduced_csv_file_path} {dimensions}",
        shell=True
    )

def taxo_cladogram(csv_file_path, cladogram_file_path):
    click.echo("Calling taxo_rSVD.R")
    subprocess.call (
        f"./taxophages/viz/taxo_cladogram.R {csv_file_path} {cladogram_file_path}",
        shell=True
    )

def taxo_all(csv, reduced_csv, dimensions, pdf, layout, filter_unknown):
    click.echo("Calling taxo_all.R")

    working_dir = os.path.dirname(os.path.realpath(__file__))
    taxo_all_script = os.path.join(working_dir, "viz/taxo_all.R")

    subprocess.call (
        f"{taxo_all_script} {csv} {reduced_csv} {pdf} {dimensions} {layout} {filter_unknown}",
        shell=True
    )
