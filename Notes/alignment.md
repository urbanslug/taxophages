Following [pangenome generate spoa cwl workflow](https://github.com/arvados/bh20-seq-resource/blob/master/workflows/pangenome-generate/pangenome-generate_spoa.cwl)

---

**1. Fetch the dataset**
```bash
FASTA_URL="https://collections.lugli.arvadosapi.com/c=e1bb8bff3420e8b478fbe8af4260d6ba-849/_/relabeledSeqs.fasta"
FASTA_FILE=data/downloaded/files/relabeledSeqs.fasta

curl --insecure -L $FASTA_URL > $FASTA_FILE
```

* **Count the number of sequences**
```bash
grep '>' $FASTA_FILE  | wc -l
33218
```

Result `33218`

**2. Sort**

```bash
SORTED_FASTA_FILE=data/downloaded/files/relabeledSeqs.sorted.fasta

python scripts/sort_fasta_by_quality_and_len.py $FASTA_FILE > $SORTED_FASTA_FILE
```

**3. Using spoa 3.4.0**

```bash
spoa --version
v3.4.0
```

* **Align**

```bash
SPOA_GRAPH=data/downloaded/files/relabeledSeqs.sorted.g6.gfa

spoa -G -g -6 $SORTED_FASTA_FILE > $SPOA_GRAPH
```

**4. Induce odgi graph**

```bash
SORTED_UNCHOPPED_ODGI_GRAPH=data/downloaded/files/relabeledSeqs.unchop.sorted.odgi

odgi build -g $SPOA_GRAPH -o - | \
    odgi unchop -i - -o - | \
    odgi sort -i - -p s -o $SORTED_UNCHOPPED_ODGI_GRAPH
```

**5. Extract coverage matrix**

```bash
COVERAGE_MATRIX=data/downloaded/files/25k.tsv
odgi paths -i $SORTED_UNCHOPPED_ODGI_GRAPH -H > $COVERAGE_MATRIX
```

**6. Fetch and insert metadata**
