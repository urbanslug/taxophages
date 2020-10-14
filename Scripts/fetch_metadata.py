#!/usr/bin/env python

import sys
from SPARQLWrapper import SPARQLWrapper, JSON
import requests
import json
import csv

args = sys.argv
input_filepath = args[1]
output_tsv_filepath = args[2]


wikidata_endpoint_url = "https://query.wikidata.org/sparql"
samples_endpoint_url = "http://collections.lugli.arvadosapi.com/c={}/metadata.yaml"


def get_results(query):
    user_agent = "WDQS-example Python/%s.%s" % (sys.version_info[0], sys.version_info[1])
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

def get_metadata(id):
    r = requests.get(samples_endpoint_url.format(id))

    if r.status_code != 200:
        return None;

    sample = json.loads(r.text);
    date = sample["sample"]["collection_date"]
    location_url = sample["sample"]["collection_location"]
    location = location_url.split("/")[-1]

    return {"location": location, "date": date}

def write_document(entries):
    with open(output_tsv_filepath, 'w', newline='') as csvfile:
        fieldnames = ['sample', 'date', 'country']
        writer = csv.DictWriter(csvfile,  dialect='excel-tab', fieldnames=fieldnames)
        writer.writeheader()

        for entry in entries:
            writer.writerow(entry)

def main():
    f = open(input_filepath, 'r')
    hashes = f.readlines()

    entries = []
    unknown = "unknwon"

    print(f'Looping over hashes from {input_filepath}')

    for hash in hashes:
        hash=hash.strip()
        metadata = get_metadata(hash)

        if metadata == None:
            entries.append({'sample': hash, 'date': unknown, 'country': unknown})
            continue

        location, date = [metadata[item] for item in ('location', 'date')]
        country = get_country(location)

        if country == None:
            country = unknwon

        entries.append({'sample': hash, 'date': date, 'country': country})

    print(f'Writing to {output_tsv_filepath}')
    write_document(entries)

main()
