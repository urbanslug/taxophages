Following [pangenome generate spoa cwl workflow][spoa workflow]
in [arvados/bh20-seq-resource/workflows/pangenome-generate/][pangenome generate]

---

### 1. Fetch the dataset
```bash
FASTA_URL="https://collections.lugli.arvadosapi.com/c=e1bb8bff3420e8b478fbe8af4260d6ba-849/_/relabeledSeqs.fasta"
FASTA_FILE=data/downloaded/files/relabeledSeqs.fasta

curl --insecure -L $FASTA_URL -o $FASTA_FILE
```

#### Count the number of sequences
```bash
grep '>' $FASTA_FILE  | wc -l
33218
```

Result `33218`

### 2. Sort

Use [sort_by_quality_and_len.py][sort] from [arvados/bh20-seq-resource/workflows/pangenome-generate/][pangenome generate]

```bash
SORTED_FASTA_FILE=data/downloaded/files/relabeledSeqs.sorted.fasta

python scripts/sort_fasta_by_quality_and_len.py $FASTA_FILE > $SORTED_FASTA_FILE
```

#### Count the number of sequences after filtering and sorting
```bash
grep '>' $SORTED_FASTA_FILE  | wc -l
25359
```

### 3. Align 

Using spoa 3.4.0
```bash
spoa --version
v3.4.0
```

```bash
SPOA_GRAPH=data/downloaded/files/relabeledSeqs.sorted.g6.gfa

spoa -G -g -6 $SORTED_FASTA_FILE > $SPOA_GRAPH
```

### 4. Induce odgi graph

```bash

ODGI_GRAPH=data/downloaded/files/relabeledSeqs.og
UNCHOPPED_ODGI_GRAPH=data/downloaded/files/relabeledSeqs.unchop.og
SORTED_UNCHOPPED_ODGI_GRAPH=data/downloaded/files/relabeledSeqs.unchop.sorted.og
SORTED_UNCHOPPED_ODGI_GFA_GRAPH=data/downloaded/files/relabeledSeqs.unchop.sorted.gfa

odgi build -g $SPOA_GRAPH -o $ODGI_GRAPH
odgi unchop -i $ODGI_GRAPH -o $UNCHOPPED_ODGI_GRAPH

odgi sort -i $UNCHOPPED_ODGI_GRAPH -p s -o $SORTED_UNCHOPPED_ODGI_GRAPH

odgi view -i $SORTED_UNCHOPPED_ODGI_GRAPH -g > $SORTED_UNCHOPPED_ODGI_GFA_GRAPH
```

### 5. Extract coverage matrix

```bash
COVERAGE_MATRIX=data/downloaded/files/25k.tsv
odgi paths -i $SORTED_UNCHOPPED_ODGI_GRAPH -H > $COVERAGE_MATRIX
```

### 6. Fetch and insert metadata
```bash
COVERAGE_MATRIX_WITH_METADATA=data/downloaded/files/25k.metadata.tsv
python main.py metadata $COVERAGE_MATRIX $COVERAGE_MATRIX_WITH_METADATA
```

### 7. Generate tree
outputs html as well

```bash
REDUCED_MATRIX=data/downloaded/files/sample.30k.metadata.reduced.tsv
SVG_FIGURE=figures/30k.700cm.svg

python main.py clado-rsvd $COVERAGE_MATRIX_WITH_METADATA $REDUCED_MATRIX $SVG_FIGURE
```

[sort]: https://github.com/arvados/bh20-seq-resource/blob/master/workflows/pangenome-generate/sort_fasta_by_quality_and_len.py
[pangenome generate]: https://github.com/arvados/bh20-seq-resource/tree/master/workflows/pangenome-generate
[spoa workflow]: https://github.com/arvados/bh20-seq-resource/blob/master/workflows/pangenome-generate/pangenome-generate_spoa.cwl