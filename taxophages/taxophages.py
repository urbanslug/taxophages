#!/usr/bin/env python

import csv
import click
from random import randint
import re
import json
import requests
from SPARQLWrapper import SPARQLWrapper, JSON
import sys

import subprocess

# Utils
# -----
def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1


def write_document(csv_file_path, fieldnames, entries):
    with open(csv_file_path, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile,  dialect='excel-tab', fieldnames=fieldnames)
        writer.writeheader()

        for entry in entries:
            writer.writerow(entry)


def read_document(csv_file_path):
    rows = []
    with open(csv_file_path, newline='') as csvfile:
        input_csv = csv.reader(csvfile, dialect='excel-tab', delimiter='\t')
        for row in input_csv:
            rows.append(row)
    return rows


def write_txt(lines, file_path, insert_newlines=False):
    if insert_newlines:
        lines = map(lambda i:(i+"\n") , lines)

    myfile = open(file_path, 'w')
    myfile.writelines(lines)
    myfile.close()


def read_txt(file_path):
    lines = []
    f = open(file_path, "r")
    lines = f.readlines()
    f.close()
    return lines


def fast_csv():
    pass

# Functionality
# -------------

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


def isolate_field(field_names, data, field):
    """Assumes the first row is the fieldnames"""
    column = []
    stripped_field_names = list(map(lambda i: i.strip(), field_names))
    idx = stripped_field_names.index(field)

    for datum in data:
        column.append(datum[idx])

    return column


def isolate_fields(input_csv, field_name, txt_path):
    rows = read_document(input_csv)

    field_names = rows[0]
    data = rows[1:]

    field = isolate_field(field_names, data, field_name)
    write_txt(field, txt_path, insert_newlines=True)

def query_arvados(id):
    samples_endpoint_url = "http://collections.lugli.arvadosapi.com/c={}/metadata.yaml"
    r = requests.get(samples_endpoint_url.format(id))

    if r.status_code != 200:
        return None;

    sample = json.loads(r.text);
    date = sample["sample"]["collection_date"]
    location_url = sample["sample"]["collection_location"]
    location = location_url.split("/")[-1]

    return {"location": location, "date": date}

def get_results(query):
    user_agent = "WDQS-example Python/%s.%s" % (sys.version_info[0], sys.version_info[1])
    wikidata_endpoint_url = "https://query.wikidata.org/sparql"

    # TODO adjust user agent; see https://w.wiki/CX6
    sparql = SPARQLWrapper(wikidata_endpoint_url, agent=user_agent)
    sparql.setQuery(query)
    sparql.setReturnFormat(JSON)
    return sparql.query().convert()

def get_country(location):
    query = """
    SELECT ?name WHERE {
      wd:%s wdt:P17 ?entity .
      ?entity wdt:P1448 ?name
    }
    LIMIT 1
    """ % (location)

    results = get_results(query)
    for result in results["results"]["bindings"]:
        if result:
            return(result["name"]["value"])
        else:
            return None


def get_metadata(hashes):
    """Get..."""
    entries = []
    for sequence_hash in hashes:
        unknown = "unknwon"
        metadata = query_arvados(sequence_hash)

        if metadata == None:
            #entries.append({'sample': sequence_hash, 'date': unknown, 'country': unknown})
            entries.append([sequence_hash, unknown, unknown])
            continue

        location, date = [metadata[item] for item in ('location', 'date')]
        country = get_country(location)

        if country == None:
            country = unknwon

        #entries.append({'sample': sequence_hash, 'date': date, 'country': country})
        entries.append([sequence_hash, date, country])

    return entries

def prepend_metadata(set1, set2):
    """prepend set1 into set2 both should be tuples"""

    combined_field_names = set1.get("field_names") + set2.get("field_names")

    set1_data = set1.get("data")
    set2_data = set2.get("data")

    set1_len = len(set1_data)
    set2_len = len(set2_data)
    if set1_len != set2_len :
        click.echo("Warning: sizes not equal. Will use shortest.")

    combined_entries = []
    for i in range(0, min(set1_len, set2_len)):
        combined_entries.append(set1_data[i] + set2_data[i])

    return {"field_names": combined_field_names, "data": combined_entries}


def loop_hashes(input_csv, csv_with_metadata):
    field_of_interest = "path.name"

    click.echo("Reading %s" % input_csv)
    rows = read_document(input_csv)

    click.echo("Isolating %s" % field_of_interest)
    field_names = rows[0]
    data = rows[1:]
    path_names = isolate_field(field_names, data, field_of_interest)

    click.echo("Extracting hashes from path names.")
    hashes = []
    pattern = "\=(.*?)\/"
    for path_name in path_names:
        substring = re.search(pattern, path_name).group(1)
        hashes.append(substring.strip())

    click.echo("Fetching metadata.")
    entries = get_metadata(hashes)

    click.echo("Prepending metadata")
    fieldnames = ['sample', 'date', 'country']
    combined = prepend_metadata({"field_names": fieldnames, "data": entries}, {"field_names": field_names, "data": data})

    click.echo("Preparing csv")

    f = combined.get("field_names")
    fd = ["\t".join(f)]
    d = combined.get("data")
    dp =  list(map(lambda x:("\t".join(x)), d))
    combined_data = fd + dp

    click.echo("Writing combined csv to %s" % csv_with_metadata)
    write_txt(combined_data, csv_with_metadata, insert_newlines=True)

def taxo_rsvd(csv_file_path, reduced_csv_file_path, dimensions):
    click.echo("Calling taxo_rSVD.R")
    subprocess.call (
        f"./taxophages/taxo_rSVD.R {csv_file_path} {reduced_csv_file_path} {dimensions}",
        shell=True
    )

def taxo_cladogram(csv_file_path, cladogram_file_path):
    click.echo("Calling taxo_rSVD.R")
    subprocess.call (
        f"./taxophages/taxo_cladogram.R {csv_file_path} {cladogram_file_path}",
        shell=True
    )

def taxo_cladogram(csv_file_path, cladogram_file_path):
    click.echo("Calling taxo_rSVD.R")
    subprocess.call (
        f"./taxophages/taxo_cladogram.R {csv_file_path} {cladogram_file_path}",
        shell=True
    )
def taxo_all(csv, reduced_csv, dimensions, pdf):
    click.echo("Calling taxo_all.R")
    subprocess.call (
        f"./taxophages/taxo_all.R {csv} {reduced_csv} {pdf} {dimensions}",
        shell=True
    )


# CLI stuff
# ---------
CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])

@click.group(context_settings=CONTEXT_SETTINGS)
def cli():
    """Taxophages: coverage matrices analysis and phylogenies"""
    pass

@cli.command()
@click.option('--threshold', default=0.1, help='The maximum percentage of Ns. Default 0.1')
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
def filter(csv, filtered_csv,  txt):
    """Filter the coverge vector using ids in txt file"""
    click.echo('Filtering large matrix %s\nto match sequences in %s\ninto %s\n' % (csv, txt, filtered_csv))
    filter_matrix(csv, filtered_csv, txt)


@cli.command()
@click.option('--size', default=100, help='Sample size. Default 100.')
@click.argument('csv')
@click.argument('sampled_csv')
def sample(size, csv, sampled_csv):
    """Number of random samples to take from a coverage matrix"""
    click.echo('Taking %s samples from %s into %s' % (size, csv, sampled_csv))
    size = int(size)
    sample_matrix(size, csv, sampled_csv)


@cli.command()
@click.argument('csv')
@click.argument('updated_csv')
def metadata(csv, updated_csv):
    """Specific to the COVID dataset. Fetch metadata using sequence ids"""
    click.echo("Using path.name field in %s to write %s" % (csv, updated_csv))
    loop_hashes(csv, updated_csv)


@cli.command()
@click.argument('csv')
@click.option('--name', help='Name of the field')
@click.argument('txt')
def extract_field(csv, name, txt):
    """Pull out a single field into a txt file"""
    click.echo("Extracting field %s into %s" % (name, txt))
    isolate_fields(csv, name.strip(), txt)

@cli.command()
@click.argument('csv')
@click.argument('reduced_csv')
# @click.option('--svd', default=True, help='Whether to perform svd or not. Default True.')
@click.option('--dimensions', default=100, help='Number of dimensions to reduce to in SVD. Default 100.')
def rsvd(csv, reduced_csv, dimensions):
    """Call rsvd script to..."""
    click.echo("Genrating cladogram from coverage matrix %s" % csv)
    dimensions = int(dimensions)
    taxo_rsvd(csv, reduced_csv, dimensions)
    click.echo("Done")

@cli.command()
@click.argument('csv')
@click.argument('pdf')
def cladogram(csv, pdf):
    """Generate a cladogram. Not yet implemented."""
    click.echo("Genrating cladogram from coverage matrix %s" % csv)
    taxo_cladogram(csv, pdf)
    click.echo("Done")

@cli.command()
@click.argument('csv')
@click.argument('reduced_csv')
@click.argument('pdf')
@click.option('--dimensions', default=100, help='Number of dimensions to reduce to in SVD. Default 100.')
def rsvd_clado(csv, reduced_csv, dimensions, pdf):
    """Generate a cladogram. Not yet implemented."""
    click.echo("Performing rsvd and generating a coverage vector")
    dimensions = int(dimensions)
    taxo_all(csv, reduced_csv, dimensions, pdf)
    click.echo("Done")


@cli.command()
@click.option('--count', default=1, help='number of repeats')
@click.argument('name')
def fun(count, name):
    """Pointless fun."""
    for x in range(count):
        click.echo('haha got your nose %s!' % name)

if __name__ == '__main__':
    cli()
