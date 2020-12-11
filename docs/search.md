# Search

## Sequence to Graph Alignment
Search for the closest sample in a graph to a given sample

#### 1. Define some vars

```sh
ODGI_GRAPH=data/mapping/relabeledSeqs.sorted_by_quality_and_len.unchop.sorted.odgi
SAMPLE=data/mapping/MMX1994-2020-11-25.fasta
ALIGNMENT=data/mapping/aln.gaf
```

#### 2. Index the graph

```sh
dozyg index -i $ODGI_GRAPH -k 15 -e 3 -t 16
```

#### 3. Map your sample to the graph
```
dozyg map -t 16 -i $ODGI_GRAPH -f $SAMPLE > $ALIGNMENT

```

#### 4. Get a coverage vector from the alignment

```sh
COV_VEC=data/mapping/aln.tsv
gaffy -v $ALIGNMENT > $COV_VEC
```

#### 5. Find the closest sample to a given one in a larger coverage matrix

```sh
SEARCH_MATRIX=data/downloaded/files/30k.tsv
QUERY_MATRIX=$COV_VEC

python main.py search $SEARCH_MATRIX $QUERY_MATRIX
```

## Using mash

As a helper taxophages can split sequences into its own file each

```
FASTA=data/30k/relabeledSeqs.sorted.fasta
REFERENCE_PATH=${HOME}/bioinfo/covid/data/search/reference

mash sketch -i -o $REFERENCE_PATH $FASTA
```

Perform the query, sort the results, select the top 10
```
REFERENCE_MIN=${REFERENCE_PATH}.msh
QUERY_SEQUENCE=data/mapping/MMX1994-2020-11-25.fasta
DISTANCE_TSV=distances.tsv


mash dist $REFERENCE_MIN $QUERY_SEQUENCE | sort -gk3 | head -n 10  $DISTANCE_TSV
```

