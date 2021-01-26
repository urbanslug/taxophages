DATASET_DIR=.
CONFIG_DIR=./config

INPUT_TREE=$1
METADATA=$2

NODE_DATA=${DATASET_DIR}/node_data.json
REFINED_TREE=${DATASET_DIR}/refined.nwk

LAT_LONGS=${CONFIG_DIR}/lat_longs.tsv
AUSPICE_CONFIG=${CONFIG_DIR}/auspice_config.json
COLOR_DATA=${CONFIG_DIR}/colors.tsv

EXPORTED_JSON=${DATASET_DIR}/covid.json

augur refine \
  --keep-root \
  --tree $INPUT_TREE \
  --metadata $METADATA \
  --output-node-data $NODE_DATA \
  --output-tree $REFINED_TREE

augur export v2 \
  --tree $REFINED_TREE \
  --metadata $METADATA \
  --node-data $NODE_DATA \
  --colors $COLOR_DATA \
  --color-by-metadata region country location date \
  --lat-longs $LAT_LONGS \
  --geo-resolutions country \
  --auspice-config $AUSPICE_CONFIG \
  --output $EXPORTED_JSON