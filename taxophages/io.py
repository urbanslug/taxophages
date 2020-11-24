#!/usr/bin/env python

import csv
import sys


def file_len(file_name):
    with open(file_name) as f:
        for i, _ in enumerate(f):
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

    my_file = open(file_path, 'w')
    my_file.writelines(lines)
    my_file.close()


def read_txt(file_path):
    lines = []
    f = open(file_path, "r")
    lines = f.readlines()
    f.close()
    return lines


def fast_csv():
    pass
