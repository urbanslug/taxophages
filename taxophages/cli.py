import click

from .base import filter_threshold, base_count, \
    filter_matrix, sample_matrix, isolate_fields, \
    taxo_all, taxo_cladogram, taxo_rsvd

from .metadata import get_and_prepend_metadata
from .search import search as naive_search

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
@click.argument('csv')
def count(fasta, csv):
    """Count number of bases & Ns in a fasta file. Outputs to a tab CSV."""
    click.echo('Performing base counting on %s and writing results to %s' % (fasta, csv))
    base_count(fasta, csv)


@cli.command()
@click.argument('csv')
@click.argument('txt')
@click.argument('filtered_csv')
def filter_csv(csv, filtered_csv,  txt):
    """Filter the coverge vector using ids in txt file"""
    click.echo('Filtering large matrix %s\nto match sequences in %s\ninto %s\n' % (csv, txt, filtered_csv))
    filter_matrix(csv, filtered_csv, txt)


@cli.command()
@click.option('-s', '--size', default=100, help='Sample size. Default 100.')
@click.argument('csv')
@click.argument('sampled_csv')
def sample(size, csv, sampled_csv):
    """
    Take a random sample from a coverage matrix.
    """
    click.echo('Taking %s random samples from %s into %s' % (size, csv, sampled_csv))
    size = int(size)
    sample_matrix(size, csv, sampled_csv)


@cli.command()
@click.argument('csv')
@click.argument('updated_csv')
def metadata(csv, updated_csv):
    """Specific to the COVID dataset. Fetch metadata using sequence ids"""
    click.echo("Using path.name field in %s to write %s" % (csv, updated_csv))
    get_and_prepend_metadata(csv, updated_csv)


@cli.command()
@click.argument('csv')
@click.option('-n', '--name', help='Name of the field')
@click.argument('txt')
def extract_field(csv, name, txt):
    """Pull out a single field into a txt file."""
    click.echo("Extracting field %s into %s" % (name, txt))
    isolate_fields(csv, name.strip(), txt)

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
@click.option('--count', default=1, help='number of repeats')
@click.argument('name')
def fun(count, name):
    """Pointless fun."""
    for _ in range(count):
        click.echo('haha got your nose %s!' % name)
