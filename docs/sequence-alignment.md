## edgyeet

### Chopped
[SPOA][1] (classic POA & [abPOA][2])
produces single nucleotide long nodes so in a sense the graph is "auto chopped".

#### Indexing
Indexing takes about a second ([../Scripts/mapping_edgyeet.sh][3]).

#### Mapping
Mapping using edgyeet ([../Scripts/mapping_edgyeet.sh][3]) with the
"chopped" graph produced the 4.0K GAF below very quickly

```
http://collections.lugli.arvadosapi.com/c=f84e8c45d6f02e3c49237d68897af29f+126/sequence.fasta   30857   309     30857   +       >60518>60519>60520>60521>60522>60524>60525>60526>60539>60540>60541>60542>60547>60548>60549>60550>60554>60555>60556>60557>60558>60559>60560>60564>60567>60570>60571>60572>60573>60574>60575>60576>60577>60579>60580>60581>60582>60583>60584>60585>60588>60589>60592>60593>60595>60596>60600>60601>60602>60603>60604>60605>60606>60607>60608>60609>60610>60611>60612>60613>60614>60615>60616>60619>60624>60626>60627>60628>60629>60631>60632>60633>60634>60635>60636>60637>60638>60639>60640>60641>60642>60644>60647>60648>60649>60651>60652>60654>60655>60656>60666>60668>60669>60670>60671>60672>60673>60674>60675      169     0       169     169     169     70      as:i:166        ta:Z:primary    cs:f:0 ac:i:0   cg:Z:166=3N
```

### Unchopped
TODO: run edgyeet with unchopped GFA


## GraphAlingner

### Chopped
GraphAligner fails to build minimizers for the SPOA graph

```
GraphAligner 1.0.10
GraphAligner 1.0.10
Load graph from data/relabeledSeqs.sorted_by_quality_and_len.g6.gfa
Build alignment graph
174868 original nodes
174868 split nodes
65830 ambiguous split nodes
277164 edges
68881 nodes with in-degree >= 2
Build minimizer seeder from the graph
GraphAligner: /gnu/store/vbrnww5jk5yik9k1x21hbxlyx38v2bv4-sdsl-lite-2.1.1/include/sdsl/int_vector.hpp:1351: sdsl::int_vector<<anonymous> >::reference sdsl::int_vector<<anonymous> >::operator[](const size_type&) [with unsigned char t_width = 0; sdsl::int_vector<<anonymous> >::reference = sdsl::int_vector_reference<sdsl::int_vector<0> >; sdsl::int_vector<<anonymous> >::size_type = long unsigned int]: Assertion `idx < this->size()' failed.
[1]    43426 abort      GraphAligner -g $COVID_GFA -f $SEQUENCES -a $OUTPUT_GA_FASTA
```

### Unchopped
Unchop the graph using odgi unchop [../Scripts/unchop.sh][4]
Align/Map using [../Scripts/mapping_graphalinger.sh][5]

```
$ GraphAligner -t 4 -g $COVID_GFA_CHOPPED -f $SEQUENCES -a $OUTPUT_GA_FASTA
GraphAligner 1.0.10
GraphAligner 1.0.10
Load graph from data/relabeledSeqs.sorted_by_quality_and_len.g6.unchop.gfa
Build alignment graph
133314 original nodes
133318 split nodes
43398 ambiguous split nodes
235614 edges
68881 nodes with in-degree >= 2
Build minimizer seeder from the graph
Minimizer seeds, length 19, window size 30, per chunk count 5, chunk size 100
Initial bandwidth 5, ramp bandwidth 10, tangle effort 10000
write alignments to output/first_sequence_graphaligner.gaf
Align
Alignment finished
Input reads: 12215 (364194140bp)
Seeds found: 106794
Seeds extended: 24425
Reads with a seed: 12215 (364194140bp)
Reads with an alignment: 12215
Alignments: 24361 (330520012bp)
End-to-end alignments: 0 (0bp)
```

Produces a 1.2G GAF file which makes more sense.

## dozyg
Like edgyeet, it indexes quickly in about a second.
Segfaults while mapping the first sequence.

```
./scripts/mapping_dozyg.sh: line 15: 19292 Segmentation fault
```

## vg giraffe


[1]: https://github.com/ekg/spoa
[2]: https://github.com/yangao07/abPOA
[3]: ../Scripts/mapping_edgyeet.sh
[4]: ../Scripts/unchop.sh
[5]: ../Scripts/mapping_graphalinger.sh