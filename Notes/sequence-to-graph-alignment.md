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
vg prune -t 24 -k 11 -e 2 > $PRUNED_XG_GRAPH

#smarter prune
vg prune -u -t 16 -k 11 -m $MAPPING $XG_GRAPH > $PRUNED_XG_GRAPH
```

### 3. Index the graph

Could be extended with -k 11 -X 2 e.g.

```sh
GCSA_INDEX=data/vg/relabeledSeqs.unchop.sorted.gcsa

vg index -g $GCSA_INDEX -f $PRUNED_XG_GRAPH
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

[1]: https://github.com/vgteam/vg/wiki/Index-Construction#with-haplotypes-or-with-many-paths
