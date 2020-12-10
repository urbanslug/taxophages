# Sequence to Graph Alignment using VG

### 1. Induce a vg compatible variation graph

```sh
GFA_GRAPH=data/vg/relabeledSeqs.unchop.sorted.gfa
VG_GRAPH=data/vg/relabeledSeqs.unchop.sorted.vg
XG_GRAPH=data/vg/relabeledSeqs.unchop.sorted.xg

# to vg graph
vg view -Fv $GFA_GRAPH > $VG_GRAPH

# to xg graph
vg convert -t 16 -x -g $GFA_GRAPH > $XG_GRAPH
```

### 2. Prune the graph

[docs](#Pruning)

#### a) Generate an empty mapping file

Based on [the vg wiki, under With haplotypes or with many paths][1],
we can create an empty mapping file which is needed by `-u` or `--unfold-paths` in `vg prune`.
```sh
MAPPING=data/vg/mapping

vg ids -m $MAPPING $XG_GRAPH
```

*"vg prune modifies the node mapping, so it is better to have a backup if we have to prune the graphs again with different parameters. It is also possible to recreate the empty mapping with vg ids -m (without option -j), but it is much slower than using a backup."*


#### b) Prune the graph
```sh
PRUNED_XG_GRAPH=data/vg/relabeledSeqs.unchop.sorted.pruned.xg

# Less complicated prune, no need for mapping
vg prune -t 24 -k 11 -e 2 $XG_GRAPH > $PRUNED_XG_GRAPH

#smarter prune
vg prune -u -t 24 -k 11 -m $MAPPING $XG_GRAPH > $PRUNED_XG_GRAPH
```

### 3. Index the graph

Could be extended with -k 11 -X 2 e.g.

```sh
GCSA_INDEX=data/vg/relabeledSeqs.unchop.sorted.gcsa

vg index -t 24 -g $GCSA_INDEX -k 11 -X 2 $XG_GRAPH
```


### Appendix
#### Pruning

```
$ vg prune -h
usage: vg prune [options] <graph.vg> >[output.vg]

Prunes the complex regions of the graph for GCSA2 indexing. Pruning the graph
removes embedded paths.

Pruning parameters:
    -k, --kmer-length N    kmer length used for pruning
                           defaults: 24 with -P; 24 with -r; 24 with -u
    -e, --edge-max N       remove the edges on kmers making > N edge choices
                           defaults: 3 with -P; 3 with -r; 3 with -u
    -s, --subgraph-min N   remove subgraphs of < N bases
                           defaults: 33 with -P; 33 with -r; 33 with -u
    -M, --max-degree N     if N > 0, remove nodes with degree > N before pruning
                           defaults: 0 with -P; 0 with -r; 0 with -u

Pruning modes (-P, -r, and -u are mutually exclusive):
    -P, --prune            simply prune the graph (default)
    -r, --restore-paths    restore the edges on non-alt paths
    -u, --unfold-paths     unfold non-alt paths and GBWT threads
    -v, --verify-paths     verify that the paths exist after pruning
                           (potentially very slow)

Unfolding options:
    -g, --gbwt-name FILE   unfold the threads from this GBWT index
    -m, --mapping FILE     store the node mapping for duplicates in this file (required with -u)
    -a, --append-mapping   append to the existing node mapping

Other options:
    -p, --progress         show progress
    -t, --threads N        use N threads (default: 56)
    -d, --dry-run          determine the validity of the combination of options

```

#### Mapping
```
$  vg ids -h
usage: vg ids [options] <graph1.vg> [graph2.vg ...] >new.vg
options:
    -c, --compact        minimize the space of integers used by the ids
    -i, --increment N    increase ids by N
    -d, --decrement N    decrease ids by N
    -j, --join           make a joint id space for all the graphs that are supplied
                         by iterating through the supplied graphs and incrementing
                         their ids to be non-conflicting (modifies original files)
    -m, --mapping FILE   create an empty node mapping for vg prune
    -s, --sort           assign new node IDs in (generalized) topological sort order
```

#### Indexing
```
usage: vg index [options] <graph1.vg> [graph2.vg ...]
Creates an index on the specified graph or graphs. All graphs indexed must
already be in a joint ID space.
general options:
    -b, --temp-dir DIR     use DIR for temporary files
    -t, --threads N        number of threads to use
    -p, --progress         show progress
xg options:
    -x, --xg-name FILE     use this file to store a succinct, queryable version of the graph(s), or read for GCSA or distance indexing
    -L, --xg-alts          include alt paths in xg
gbwt options:
    -v, --vcf-phasing FILE generate threads from the haplotypes in the VCF file FILE
    -W, --ignore-missing   don't warn when variants in the VCF are missing from the graph; silently skip them
    -e, --parse-only FILE  store the VCF parsing with prefix FILE without generating threads
    -T, --store-threads    generate threads from the embedded paths
    --paths-as-samples     interpret the paths as samples instead of contigs in -T
    -M, --store-gam FILE   generate threads from the alignments in gam FILE (many allowed)
    -F, --store-gaf FILE   generate threads from the alignments in gaf FILE (many allowed)
    -G, --gbwt-name FILE   store the threads as GBWT in FILE
    -z, --actual-phasing   do not make unphased homozygous genotypes phased
    -P, --force-phasing    replace unphased genotypes with randomly phased ones
    -o, --discard-overlaps skip overlapping alternate alleles if the overlap cannot be resolved
    -B, --batch-size N     number of samples per batch (default 200)
    -u, --buffer-size N    GBWT construction buffer size in millions of nodes (default 100)
    -n, --id-interval N    store haplotype ids at one out of N positions (default 1024)
    -R, --range X..Y       process samples X to Y (inclusive)
    -r, --rename V=P       rename contig V in the VCFs to path P in the graph (may repeat)
    --rename-variants      when renaming contigs, find variants in the graph based on the new name
    -I, --region C:S-E     operate on only the given 1-based region of the given VCF contig (may repeat)
    -E, --exclude SAMPLE   exclude any samples with the given name from haplotype indexing
gcsa options:
    -g, --gcsa-out FILE    output a GCSA2 index to the given file
    -i, --dbg-in FILE      use kmers from FILE instead of input VG (may repeat)
    -f, --mapping FILE     use this node mapping in GCSA2 construction
    -k, --kmer-size N      index kmers of size N in the graph (default 16)
    -X, --doubling-steps N use this number of doubling steps for GCSA2 construction (default 4)
    -Z, --size-limit N     limit temporary disk space usage to N gigabytes (default 2048)
    -V, --verify-index     validate the GCSA2 index using the input kmers (important for testing)
gam indexing options:
    -l, --index-sorted-gam input is sorted .gam format alignments, store a GAI index of the sorted GAM in INPUT.gam.gai
vg in-place indexing options:
    --index-sorted-vg      input is ID-sorted .vg format graph chunks, store a VGI index of the sorted vg in INPUT.vg.vgi
rocksdb options:
    -d, --db-name  <X>     store the RocksDB index in <X>
    -m, --store-mappings   input is .gam format, store the mappings in alignments by node
    -a, --store-alignments input is .gam format, store the alignments by node
    -A, --dump-alignments  graph contains alignments, output them in sorted order
    -N, --node-alignments  input is (ideally, sorted) .gam format,
                           cross reference nodes by alignment traversals
    -D, --dump             print the contents of the db to stdout
    -C, --compact          compact the index into a single level (improves performance)
snarl distance index options
    -s  --snarl-name FILE  load snarls from FILE
    -j  --dist-name FILE   use this file to store a snarl-based distance index
    -w  --max_dist N       cap beyond which the maximum distance is no longer accurate. If this is not included or is 0, don't build maximum distance index

```

[1]: https://github.com/vgteam/vg/wiki/Index-Construction#with-haplotypes-or-with-many-paths
