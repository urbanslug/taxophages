PROJECT_DIR=${HOME}/bioinfo/experiments
DATA_DIR=${PROJECT_DIR}/data
OUTPUT_DIR=${PROJECT_DIR}/output

PGGB_GRAPH=${DATA_DIR}/DRB1-3123.fa.gz.pggb-s3000-p70-n10-a70-K16-k8-w10000-j5000-e5000.smooth.gfa
NAME=DRB1-3123
ODGI_GRAPH=${DATA_DIR}/${NAME}.odgi.gfa
COVERAGE_MATRIX=${OUTPUT_DIR}/${NAME}_matrix.tsv



# Build an odgi graph
odgi build -g $PGGB_GRAPH -o $ODGI_GRAPH

# Get the paths for each sample in a matrix
odgi paths -i $ODGI_GRAPH -H > $COVERAGE_MATRIX
