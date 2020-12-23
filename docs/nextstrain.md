## Generate the tree

Set vars (in this case for 25k sequences).

```bash
DATASET_ID=25k
DATASET_DIR=data/trees/30k

CSV=${DATASET_DIR}/covmatrix.${DATASET_ID}.metadata.tsv
REDUCED_MATRIX=${DATASET_DIR}/reduced.${DATASET_ID}.tsv
METADATA=${DATASET_DIR}/metadata.${DATASET_ID}.tsv
NEWICK_TREE=${DATASET_DIR}/${DATASET_ID}.nwk

DIMENSIONS=100
FILTER_UNKNOWNS=TRUE
```

Generate the tree in newick format.

``` bash
TAXOPHAGES_ENV=server \
R_PACKAGES=${HOME}/RLibraries \
./taxophages/viz/nextstrain.R \
  $CSV $REDUCED_MATRIX $METADATA $NEWICK_TREE $DIMENSIONS $FILTER_UNKNOWNS
```

## Visualize it in nextstrain

Set vars needed to generate the nextstrain visualization.
```bash
DATASET_DIR=.

INPUT_TREE=${DATASET_DIR}/${DATASET_ID}.nwk
NODE_DATA=${DATASET_DIR}/node_data.json
REFINED_TREE=${DATASET_DIR}/refined.${DATASET_ID}.nwk
METADATA=${DATASET_DIR}/metadata.${DATASET_ID}.tsv

LAT_LONGS=${DATASET_DIR}/lat_longs.tsv
AUSPICE_CONFIG=${DATASET_DIR}/auspice_config.json

EXPORTED_JSON=${DATASET_DIR}/covid.json
```

Generate the files needed by nexstrain from the newick tree.

```bash
augur refine \
  --tree $INPUT_TREE \
  --metadata $METADATA \
  --output-node-data $NODE_DATA \
  --output-tree $REFINED_TREE

augur export v2 \
  --tree $REFINED_TREE \
  --metadata $METADATA \
  --node-data $NODE_DATA \
  --color-by-metadata region country location date \
  --lat-longs $LAT_LONGS \
  --geo-resolutions country \
  --auspice-config $AUSPICE_CONFIG \
  --output $EXPORTED_JSON
```

Visualize the tree in your browser

```bash
auspice view --datasetDir $DATASET_DIR
```



