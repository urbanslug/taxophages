# Taxophages
A tool for generating cladograms and analyzing sequences from pangenomes.

Tightly coupled with data from
[COVID-19 PubSeq: Public SARS-CoV-2 Sequence Resource](http://covid19.genenetwork.org/) (for now).

## Demo
The kind of cladogram that taxophages can generate is here, [an rsvd tree for ~25k sequences](urbanslug.github.io/taxophages/).

## Documentation 
Refer to the [docs directory](./docs).

## Running

```
$ python  main.py -h

Usage: main.py [OPTIONS] COMMAND [ARGS]...

  Taxophages: coverage matrix analysis and phylogenetics

Options:
  -h, --help  Show this message and exit

Commands:
  clado-rsvd     Combines cladogram and rsvd
  cladogram      Compute pairwise distances and generate a cladogram
  count          Count number of bases & Ns in a fasta file
  extract-field  Pull out a single field into a txt file
  filter-csv     Filter the coverage vector using ids in txt file
  fun            Pointless fun
  metadata       Specific to the COViD dataset
  qc             Filter sequences for Ns below given threshold
  rsvd           Perform rsvd on a coverage matrix
  sample         Take a random sample from a coverage matrix
```
