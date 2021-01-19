import click
import subprocess
import os
from .io import read_document, write_txt
from Bio import SeqIO

def mash_dist_to_matrix(distances, sequence_count):
    distance_matrix = [ [ None for i in range(sequence_count) ] for j in range(sequence_count) ]

    for row_index, row in enumerate(distance_matrix):
        for column_index, _ in enumerate(row):
            distances_index = sequence_count*row_index+column_index
            distance_matrix[row_index][column_index] = distances[distances_index][2]

    return distance_matrix

def do_mash(fasta, distance_matrix_path, newick_tree_path):

    reference_path = "/tmp/chickenfoot"
    distances_path = "/tmp/distances"
    metadata_path = "/tmp/metadata"

    click.echo("sketching")
    subprocess.call (
        f"mash sketch -p 16 -i -o {reference_path} {fasta}",
        shell=True
    )

    click.echo("distances")
    subprocess.call (
        f"mash dist -i {reference_path}.msh {fasta} > {distances_path}",
        shell=True
    )

    sequences = list(SeqIO.parse(open(fasta),'fasta'))
    sequence_count = len(sequences)

    metadata = ['label']
    for seq in sequences:
        metadata.append(seq.id)
    write_txt(metadata, metadata_path, insert_newlines=True)

    click.echo("Reading distances")
    distances = read_document(distances_path)
    distance_matrix = mash_dist_to_matrix(distances, sequence_count)

    tabbed_matrix = ['\t'.join(row) for row in distance_matrix]

    click.echo("Writing distance matrix")
    write_txt(tabbed_matrix, distance_matrix_path, insert_newlines=True)

    subprocess.call (
        f"./taxophages/viz/distance_matrix_to_tree.R {distance_matrix_path} {metadata_path} {newick_tree_path}",
        shell=True
    )

    click.echo("Cleaning up")
    for f in [f"{reference_path}.msh", distances_path, metadata_path]:
        os.remove(f)
