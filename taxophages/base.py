#!/usr/bin/env python
import os
import re

import csv
import click
from random import randint
import subprocess

from .io import file_len, write_document, read_document, write_txt, read_txt
from .utils import isolate_field

from Bio import SeqIO

from functools import reduce

def select_sequences(fasta, txt_path, filtered_fasta_path):
    """
    """
    sequences = list(SeqIO.parse(open(fasta),'fasta'))
    filter_sequences = read_txt(txt_path)
    filter_sequences = [x.strip() for x in filter_sequences]

    selected = []

    with click.progressbar(sequences, 
    label='Selecting sequences') as seqs:
        for sequence in seqs:
            foo = '>'+sequence.id
            if foo in filter_sequences:
                selected.append('>'+sequence.id)
                selected.append(str(sequence.seq))
    
    click.echo("Writing to %s" % filtered_fasta_path)
    write_txt(selected, filtered_fasta_path, True)

def generate_set_of_random_values(start, end, size):
    """
    Generate unique random integers
    """
    random_integers = set()

    while (len(random_integers) < size):
        random_int = randint(start, end)
        random_integers.add(random_int)

    return random_integers

def sample_sequences(size, fasta, sampled_fasta):
    """
    """
    sequences = list(SeqIO.parse(open(fasta),'fasta'))
    sequence_count = len(sequences)

    if size > len(sequences):
        raise Exception("Sample size larger than number of sequences")

    click.echo("Generating random values")
    random_indexes = generate_set_of_random_values(0, sequence_count-1, size)

    click.echo("Selecting sequences")
    sampled = []
    with click.progressbar(random_indexes) as rands:
        for i in rands:
            fasta = sequences[i]
            sampled.append('>'+fasta.id)
            sampled.append(str(fasta.seq))

    write_txt(sampled, sampled_fasta, True)

def split_fasta(fasta, output_dir):
    """
    """
    if not os.path.isdir(output_dir):
        raise Exception("Output directory does not exist")

    sequences = SeqIO.parse(open(fasta),'fasta')

    click.echo("Generating files")
    pattern =  r"lugli[a-z0-9-]*"
    with click.progressbar(sequences) as seqs:
        for sequence in seqs:
            seq_id = sequence.id
            entry = ['>'+seq_id, str(sequence.seq)]
            file_name = re.search(pattern, seq_id).group()
            output_file = os.path.join(output_dir, file_name)
            write_txt(entry, output_file, True)

def prep_q(fasta, output_fasta):
    sequence = SeqIO.parse(open(fasta),'fasta').__next__()

    seq_id = sequence.id
    entry = ['>'+seq_id, str(sequence.seq)]
    write_txt(entry, output_fasta, True)

def isolate_fields(input_csv, fields_to_extract, extracted_tsv_path, keep_headers):
    rows = read_document(input_csv)

    field_names = rows[0]
    data = rows[1:]

    extracted = []
    for field_to_extract in fields_to_extract:
        foo = isolate_field(field_names, data, field_to_extract)
        extracted.append(foo)

    zipped_data = zip(*extracted)
    tabbed_data = ['\t'.join(x) for x in zipped_data]
    
    result = ['\t'.join(fields_to_extract)] + tabbed_data if keep_headers else tabbed_data
    
    click.echo("Writing extracted fields to %s" % extracted_tsv_path)
    write_txt(result, extracted_tsv_path, insert_newlines=True)

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
