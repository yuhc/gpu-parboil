#!/usr/bin/env bash

set -o errexit -o nounset -o posix -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# 10 in total
# mri-gridding does not work because of no-enough-memory
bm="bfs cutcp histo lbm mri-q sgemm spmv stencil tpacf"

OUTDIR=$DIR/results/
mkdir -p $OUTDIR

exe() { echo "++ $@" |& tee -a $OUTDIR/$b.txt ;  if [[ "$1" == "export" ]]; then $@ ; fi ;  $@ |& tee -a $OUTDIR/$b.txt ; }

for b in $bm; do
	echo -n > $OUTDIR/$b.txt #clean output file
	exe echo "running $b"
	exe date
	exe uname -a
	[[ -x /usr/bin/hwloc-ls ]] && exe hwloc-ls
	exe export GOMP_CPU_AFFINITY=0-1024 KMP_AFFINITY=explicit,verbose,proclist=[0-1024]
    for idx in `seq 1 10`; do
    	#exe sudo -E perf stat -A -a -e instructions,cache-misses,cache-references,cycles ./parboil run --no-check $b omp_base large
    	#exe sudo -E perf stat -A -a -e \
        #instructions,cache-misses,cache-references,cycles ./parboil run \
        #--no-check $b opencl_nvidia large
    	exe time ./parboil run --no-check $b opencl_nvidia large

    done
	echo
done
