import click
import subprocess
import os
from .io import read_document, write_txt
from Bio import SeqIO
from .metadata import get_metadata

def mash_dist_to_matrix(distances, sequence_count):
    distance_matrix = [ [ None for i in range(sequence_count) ] for j in range(sequence_count) ]

    for row_index, row in enumerate(distance_matrix):
        for column_index, _ in enumerate(row):
            distances_index = sequence_count*row_index+column_index
            distance_matrix[row_index][column_index] = distances[distances_index][2]

    return distance_matrix

def do_mash(fasta, distance_matrix_path, output_path, width, height):
    reference_path = "/tmp/chickenfoot"
    distances_path = "/tmp/distances"
    metadata_path = "/tmp/metadata"

    click.echo("Performing mash sketch")
    subprocess.call (
        f"mash sketch -p 16 -i -o {reference_path} {fasta}",
        shell=True
    )

    click.echo("Performing mash dist")
    subprocess.call (
        f"mash dist -i {reference_path}.msh {fasta} > {distances_path}",
        shell=True
    )

    sequences = list(SeqIO.parse(open(fasta),'fasta'))
    sequence_count = len(sequences)

    sequence_identifiers = []
    fieldnames = ['label', 'date', 'location', 'country', 'region']

    for seq in sequences:
        sequence_identifiers.append("lugli-4zz18-"+seq.id)

    metadata = get_metadata(sequence_identifiers)
    tabbed_metadata = ['\t'.join(row) for row in metadata]
    tabbed_fieldnames = ["\t".join(fieldnames)]

    tb = tabbed_fieldnames + tabbed_metadata
    write_txt(tb, metadata_path, insert_newlines=True)

    click.echo("Reading distances")
    distances = read_document(distances_path)
    distance_matrix = mash_dist_to_matrix(distances, sequence_count)

    tabbed_matrix = ['\t'.join(row) for row in distance_matrix]

    click.echo("Writing distance matrix")
    write_txt(tabbed_matrix, distance_matrix_path, insert_newlines=True)

    click.echo("Generating tree")
    subprocess.call (
        f"./taxophages/viz/distance_matrix_to_tree.R {distance_matrix_path} {metadata_path} {output_path}.nwk {output_path}.pdf {width} {height}",
        shell=True
    )

    click.echo("Cleaning up")
    for f in [f"{reference_path}.msh", distances_path, metadata_path]:
        click.echo(f"  Deleting {f}")
        os.remove(f)
