Following [pangenome generate spoa cwl workflow](https://github.com/arvados/bh20-seq-resource/blob/master/workflows/pangenome-generate/pangenome-generate_spoa.cwl)

---

**1. Fetch the dataset**
```
fasta_url="https://collections.lugli.arvadosapi.com/c=e1bb8bff3420e8b478fbe8af4260d6ba-849/_/relabeledSeqs.fasta"
fasta_file=data/downloaded/files/relabeledSeqs.fasta

curl --insecure -L $fasta_url > $fasta_file
```
* **Count the number of sequences**
```
grep '>' $fasta_file  | wc -l
33218
```

Result `33218`

**2. Sort**
```
python scripts/sort_fasta_by_quality_and_len.py data/downloaded/files/relabeledSeqs.fasta > data/downloaded/files/relabeledSeqs.sorted.fasta
```

**3. Using spoa 3.4.0**
```
spoa --version
v3.4.0
```

* **Align**
```
spoa -G -g -6 data/downloaded/files/relabeledSeqs.sorted.fasta > data/downloaded/files/relabeledSeqs.sorted.g6.gfa
```

**4. Induce odgi graph**
```
SPOA_GRAPH=data/downloaded/files/relabeledSeqs.sorted.g6.gfa
SORTED_UNCHOPPED_ODGI_GRAPH=data/downloaded/files/relabeledSeqs.unchop.sorted.odgi
```


```
odgi build -g $SPOA_GRAPH -o - | \
    odgi unchop -i - -o - | \
    odgi sort -i - -p s -o $SORTED_UNCHOPPED_ODGI_GRAPH
```

**5. Extract coverage matrix**
```
COVERAGE_MATRIX=data/downloaded/files/25k.tsv
odgi paths -i $SORTED_UNCHOPPED_ODGI_GRAPH -H > $COVERAGE_MATRIX
```

**6. Fetch and insert metadata**
