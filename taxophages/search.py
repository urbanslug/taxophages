from .io import file_len, write_document, read_document, write_txt, read_txt
import numpy
import sys
import click
from math import floor


def search(tsv, query_tsv):
    click.echo("Reading %s" % tsv)
    search_space = read_document(tsv)

    click.echo("Reading %s" % query_tsv)
    query = read_document(query_tsv)

    click.echo("Preprocessing")
    search_matrix = search_space[1:]
    query_matrix = query[1]
    cut = min(len(search_matrix[0]), len(query_matrix)) - 1
    click.echo("Truncating coverage vectors at %s" % cut)

    click.echo("Finding the closest sample")
    string_to_int = lambda l : [int(i) for i in l]
    dist = ("", sys.maxsize)
    with click.progressbar(search_matrix) as samples:
        for sample in samples:
            a = string_to_int(query_matrix[3:cut])
            b = string_to_int(sample[3:cut])

            delta = numpy.linalg.norm(numpy.array(a) - numpy.array(b))

            if (delta < dist[1]):
                dist = (sample[0], delta)

    query_name = query_matrix[0]
    click.echo("The sample closest to %s is %s" % (query_name, dist[0]))