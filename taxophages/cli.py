import click

from .base import filter_threshold, base_count, \
    filter_matrix, sample_matrix, sample_sequences, prep_q, split_fasta, isolate_fields, \
    taxo_all, taxo_cladogram, taxo_rsvd, select_sequences

from .metadata import get_and_prepend_metadata
from .search import search as naive_search
from .prune import prune as prune_matrix
from .utils import make_str_list
from .distance import do_mash

CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])

@click.group(context_settings=CONTEXT_SETTINGS)
def cli():
    """
    Taxophages: coverage matrix analysis and phylogenetics
    """
    pass

@cli.command()
@click.option('-t', '--threshold', default=0.1, help='The maximum percentage of Ns. Default 0.1')
@click.argument('csv')
@click.argument('txt')
def qc(csv, txt, threshold):
    """Filter sequences for Ns below given threshold."""
    click.echo('Filtering with N threshold of %s' % threshold)
    filter_threshold(csv, txt, threshold)


@cli.command()
@click.argument('fasta')
@click.argument('tsv')
def count(fasta, tsv):
    """Count number of bases & Ns in a fasta file. Outputs to a TSV."""
    click.echo('Performing base counting on %s and writing results to %s' % (fasta, tsv))
    base_count(fasta, tsv)


@cli.command()
@click.argument('csv')
@click.argument('txt')
@click.argument('filtered_csv')
def select_csv(csv, filtered_csv,  txt):
    """Select rows from a coverge vector based on ids a txt file"""
    click.echo('Filtering large matrix %s\nto match sequences in %s\ninto %s\n' % (csv, txt, filtered_csv))
    filter_matrix(csv, filtered_csv, txt)

@cli.command()
@click.argument('fasta')
@click.argument('txt')
@click.argument('filtered_fasta')
def select_fasta(fasta, txt,  filtered_fasta):
    """Select samples from a fasta file based on ids a txt file"""
    click.echo('Selecting sequences from %s\nto match sequences in %s\ninto %s\n' % (fasta, txt, filtered_fasta))
    select_sequences(fasta, txt, filtered_fasta)

@cli.command()
@click.option('-s', '--size', default=100, help='Sample size. Default 100.')
@click.argument('csv')
@click.argument('sampled_csv')
def sample_coverage(size, csv, sampled_csv):
    """
    Take a random sample from a coverage matrix.
    """
    click.echo('Taking %s random samples from %s into %s' % (size, csv, sampled_csv))
    size = int(size)
    sample_matrix(size, csv, sampled_csv)

@cli.command()
@click.option('-s', '--size', default=100, help='Sample size. Default 100.')
@click.argument('fasta')
@click.argument('sampled_fasta')
def sample_fasta(size, fasta, sampled_fasta):
    """
    Take a random sample of sequences from a fasta file
    """
    click.echo('Taking %s random samples from %s into %s' % (size, fasta, sampled_fasta))
    size = int(size)
    sample_sequences(size, fasta, sampled_fasta)

@cli.command()
@click.argument('fasta')
@click.argument('output_dir')
def split_sequences(fasta, output_dir):
    """
    Create a file from each fasta entry
    """
    split_fasta(fasta, output_dir)

@cli.command()
@click.argument('fasta')
@click.argument('output_fasta')
def prepare_query(fasta, output_fasta):
    """
    Create a file from each fasta entry
    """
    prep_q(fasta, output_fasta)

@cli.command()
@click.argument('csv')
@click.argument('updated_csv')
@click.option('-u', '--url-field', default="path.name", help='Name of the field containing the URL')
def get_metadata(csv, updated_csv, url_field):
    """Specific to the COVID dataset. Fetch metadata using sequence ids"""
    click.echo("Using path.name field in %s to write %s" % (csv, updated_csv))
    get_and_prepend_metadata(csv, updated_csv, url_field)

@cli.command()
@click.argument('tsv')
@click.option('-n', '--name', help='Name of the field', multiple=True)
@click.option('-k', '--keep-headers', default=True, help='Keep headers in TSV')
@click.argument('extracted_tsv')
def extract_field(tsv, name, extracted_tsv, keep_headers):
    """Extract a field or fields from a coverage matrix tsv"""

    if keep_headers and keep_headers != "True":
        keep_headers = False

    print(keep_headers)

    names = make_str_list(name)
    click.echo("Extracting field(s) %s into %s" % (names, extracted_tsv))
    isolate_fields(tsv, name, extracted_tsv, keep_headers)

@cli.command()
@click.argument('csv')
@click.argument('reduced_csv')
@click.option('-d', '--dimensions', default=100, help='Number of dimensions to reduce to in SVD. Default 100.')
def rsvd(csv, reduced_csv, dimensions):
    """Perform rsvd on a coverage matrix."""
    click.echo("Performing rsvd on: %s" % csv)
    dimensions = int(dimensions)
    taxo_rsvd(csv, reduced_csv, dimensions)
    click.echo("Done")

# should incorporate direct
@cli.command()
@click.argument('csv')
@click.argument('pdf')
def cladogram(csv, pdf):
    """
    Compute pairwise distances and generate a cladogram.
    """
    click.echo("Genrating cladogram from coverage matrix: %s" % csv)
    taxo_cladogram(csv, pdf)
    click.echo("Done")

@cli.command()
@click.argument('csv')
@click.argument('reduced_csv')
@click.argument('pdf')
@click.option('-f', '--filter-unknown', default=True, help='Filter fields that are unknown')
@click.option('-l', '--layout', default="rectangular", help='tree layout')
@click.option('-d', '--dimensions', default=100, help='Number of dimensions to reduce to in SVD. Default 100.')
def clado_rsvd(csv, filter_unknown, reduced_csv, dimensions, layout, pdf):
    """
    Combines cladogram and rsvd.
    Generate cladogram from rsvd reduced distance matrix.
    """
    click.echo("Performing rsvd and generating a coverage vector")
    dimensions = int(dimensions)
    taxo_all(csv, reduced_csv, dimensions, pdf,  layout, filter_unknown)
    click.echo("Done")

@cli.command()
@click.argument('tsv')
@click.argument('query_tsv')
def search(tsv, query_tsv):
    """
    Search for the closest sequence to a given query tsv
    Injects this new tsv into the existing one and calculates pairwise distance comparisons
    """
    click.echo("Searching for the closest sequence to %s in %s" % (query_tsv, tsv))
    naive_search(tsv, query_tsv)
    click.echo("Done")

@cli.command()
@click.argument('distance_matrix')
@click.argument('metadata')
@click.argument('pruned_metadata')
@click.argument('neighbor_tsv')
def prune(distance_matrix, metadata, pruned_metadata, neighbor_tsv):
    """
    Remove samples close to each other reducing the size of the coverage amtrix
    """
    prune_matrix(distance_matrix, metadata, pruned_metadata, neighbor_tsv)
    click.echo("Done")

@cli.command()
@click.option('--count', default=1, help='number of repeats')
@click.argument('name')
def fun(count, name):
    """Pointless fun."""
    for _ in range(count):
        click.echo('haha got your nose %s!' % name)

@cli.command()
@click.argument('fasta')
@click.argument('distance_matrix')
@click.argument('output_path')
@click.option('-x', '--width', default=20, help='number of repeats')
@click.option('-y', '--height', default=35, help='number of repeats')
def mash_distance(fasta, distance_matrix, output_path, width, height):
    """Requires mash, calculate pairwise distances"""
    do_mash(fasta, distance_matrix, output_path, width, height)
