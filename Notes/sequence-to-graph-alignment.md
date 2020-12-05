# Sequence to Graph Alignment using VG


### 1. Induce a vg compatible variation graph

```
GFA_GRAPH=data/vg/relabeledSeqs.unchop.sorted.gfa
VG_GRAPH=data/vg/relabeledSeqs.unchop.sorted.vg
XG_GRAPH=data/vg/relabeledSeqs.unchop.sorted.xg

# to vg graph
vg view -Fv $GFA_GRAPH > $VG_GRAPH

# to xg graph
vg convert -t 16 -x -g $GFA_GRAPH > $XG_GRAPH
```

### 2. Prune the graph

#### a) Generate an empty mapping file

Based on [the vg wiki, under With haplotypes or with many paths][1],
we can create an empty mapping file which is needed by `-u` or `--unfold-paths` in `vg prune`.
```
MAPPING=data/vg/mapping

vg ids -m $MAPPING $XG_GRAPH
```


*vg prune modifies the node mapping, so it is better to have a backup if we have to prune the graphs again with different parameters. It is also possible to recreate the empty mapping with vg ids -m (without option -j), but it is much slower than using a backup.*


#### b) Prune the graph
```
PRUNED_XG_GRAPH=data/vg/relabeledSeqs.unchop.sorted.pruned.xg

vg prune -u -k 11 -m $MAPPING $XG_GRAPH > $PRUNED_XG_GRAPH
```

### 3. Index the graph

Could be extended with -k 11 -X 2 e.g.

```
GCSA_INDEX=data/vg/relabeledSeqs.unchop.sorted.gcsa

vg index -g $GCSA_INDEX -f $PRUNED_XG_GRAPH
```

[1]: https://github.com/vgteam/vg/wiki/Index-Construction#with-haplotypes-or-with-many-paths