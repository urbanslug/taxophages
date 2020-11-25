import csv
import click
from random import randint
import re

import requests
import urllib
from SPARQLWrapper import SPARQLWrapper, JSON
import sys
import subprocess

import json
import yaml


from .io import file_len, write_document, read_document, write_txt, read_txt
from .utils import isolate_field

countries = []
unknown = "unknown"

def query_arvados(id):
    samples_endpoint_url = "http://collections.lugli.arvadosapi.com/c={}/metadata.yaml"
    r = requests.get(samples_endpoint_url.format(id))

    if r.status_code != 200:
        return None

    try:
        metadata = json.loads(r.text)
    except json.decoder.JSONDecodeError:
        metadata = yaml.load(r.text, Loader=yaml.FullLoader)

    sample = metadata["sample"]
    date = sample["collection_date"]
    location_url = sample["collection_location"]
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
    query = \
        """
        SELECT DISTINCT ?countryName ?location WHERE {
          wd:%s rdfs:label ?location .
          FILTER (langMatches( lang(?location),  "EN" ) )

          wd:%s wdt:P17 ?country .

          # country
          ?country rdfs:label ?countryName .
          FILTER (langMatches( lang(?countryName),  "EN" ) )
        } LIMIT 1
        """ % (location, location)

    try:
        results = get_results(query)
        bindings = results["results"]["bindings"][0]
        country = bindings["countryName"]["value"]
        loc = bindings["location"]["value"]

        region = lookup_region(country)
        if region is None:
            region = unknown

        return {"country": country, "region": region, "location": loc}
    except IndexError as exception:
        print("Exception: %s Location: %s" % (exception, location))
        return None
    except urllib.error.HTTPError as exception:
        print("Exception: %s Location: %s" % (exception, location))
        return None
    except KeyError:
        return None

def lookup_region(country):
    res = list(filter(lambda x: x[0] == country,  countries))
    try:
        return res[0][6]
    except IndexError:
        print(country)
        return None

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

def get_metadata(sequence_identifiers):
    """
    Get metadata associated with a given sequence identifier
    """
    # entries is a lists of lists containing sample, date, country, region
    global countries
    countries = read_document("./taxophages/countries.csv")
    entries = []

    for sequence_identifier in sequence_identifiers:
        unknown = "unknown"
        metadata = query_arvados(sequence_identifier)

        if metadata == None:
            #entries.append({'sample': sequence_hash, 'date': unknown, 'country': unknown})
            entries.append([sequence_identifier, unknown, unknown, unknown, unknown])
            continue

        location, date = [metadata[item] for item in ('location', 'date')]
        geo = get_country(location)

        if geo == None:
            entries.append([sequence_identifier, date, unknown, unknown, unknown])
        else:
            country, region, loc = [geo[item] for item in ('country', 'region', 'location')]
            entries.append([sequence_identifier, date, loc, country, region])

    return entries


def get_and_prepend_metadata(input_csv, csv_with_metadata):
    """
    Given a CSV look into the field name path.name and fetch the
    metadata for that file
    """
    field_of_interest = "path.name"

    click.echo("Reading %s" % input_csv)
    rows = read_document(input_csv)

    click.echo("Isolating %s" % field_of_interest)
    field_names = rows[0]
    data = rows[1:]
    permalinks = isolate_field(field_names, data, field_of_interest)

    click.echo("Extracting hashes from path names.")
    sequence_identifiers = []
    pattern =  r"lugli[a-z0-9-]*"
    for permalink in permalinks:
        substring = re.search(pattern, permalink).group()
        sequence_identifiers.append(substring.strip())

    click.echo("Fetching metadata.")
    entries = get_metadata(sequence_identifiers)

    click.echo("Prepending metadata")
    fieldnames = ['sample', 'date', 'location', 'country', 'region']
    combined = prepend_metadata(
        {"field_names": fieldnames, "data": entries},
        {"field_names": field_names, "data": data}
    )

    click.echo("Preparing csv")

    f = combined.get("field_names")
    fd = ["\t".join(f)]
    d = combined.get("data")
    dp =  list(map(lambda x:("\t".join(x)), d))
    combined_data = fd + dp

    click.echo("Writing updated csv to %s" % csv_with_metadata)
    write_txt(combined_data, csv_with_metadata, insert_newlines=True)


def fetch_metadata():
    pass