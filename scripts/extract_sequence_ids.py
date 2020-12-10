#!/usr/bin/env python

import sys
import csv
import re

args = sys.argv
input_csv_filepath = args[1]
output_filepath = args[2]

pattern = "\=(.*?)\/"


def extract_headers():
  headers = []
  with open(input_csv_filepath, newline='') as csvfile:
    input_csv = csv.reader(csvfile, dialect='excel-tab', delimiter='\t')
    for row in input_csv:
      s = row[1]
      print(s)
      substring = re.search(pattern, s).group(1)
      headers.append(substring)
  return headers

def write_headers(h):
  myfile = open(output_filepath, 'w')
  myfile.writelines(h)
  myfile.close()

def main():
  h = extract_headers()
  write_headers(h)

main()
