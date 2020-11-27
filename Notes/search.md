
## Search

Search for the closest sample in a graph to a given sample

1. Define some vars

```bash
ODGI_GRAPH=data/mapping/relabeledSeqs.sorted_by_quality_and_len.unchop.sorted.odgi
SAMPLE=data/mapping/MMX1994-2020-11-25.fasta
ALIGNMENT=data/mapping/aln.gaf

```

2. Index the graph

```bash
dozyg index -i $ODGI_GRAPH -k 15 -e 3 -t 16
```

3. Map your sample to the graph
```
dozyg map -t 16 -i $ODGI_GRAPH -f $SAMPLE > $ALIGNMENT

```

4. Get a coverage vector from the alignment
```sh
COV_VEC=data/mapping/aln.tsv
gaffy -v $ALIGNMENT > $COV_VEC
```

5. Find the closest sample to a given one in a larger coverage matrix
```bash
SEARCH_MATRIX=data/downloaded/files/30k.tsv
QUERY_MATRIX=$COV_VEC

python main.py search $SEARCH_MATRIX $QUERY_MATRIX
```

