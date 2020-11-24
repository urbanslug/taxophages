# Taxophages
A tool for generating cladograms and analyzing sequences.

Currently tightly coupled to [COVID-19 PubSeq: Public SARS-CoV-2 Sequence Resource](http://covid19.genenetwork.org/)

## Demo
Example output: [rsvd tree for ~7k sequences](urbanslug.github.io/taxophages/)

## Install deps

Advisable to use a virualenv
```
pip install -r requirements/base.pip
```

## Running

```
$ python  main.py -h

Usage: main.py [OPTIONS] COMMAND [ARGS]...

  Taxophages: coverage matrix analysis and phylogenetics

Options:
  -h, --help  Show this message and exit.

Commands:
  clado-rsvd     Combines cladogram and rsvd.
  cladogram      Compute pairwise distances and generate a cladogram.
  count          Count number of bases & Ns in a fasta file.
  extract-field  Pull out a single field into a txt file.
  filter-csv     Filter the coverge vector using ids in txt file
  fun            Pointless fun.
  metadata       Specific to the COVID dataset.
  qc             Filter sequences for Ns below given threshold.
  rsvd           Perform rsvd on a coverage matrix.
  sample         Take a random sample from a coverage matrix.
```
