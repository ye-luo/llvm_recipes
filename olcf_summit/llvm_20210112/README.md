1. edit install_path in upstream-script.sh. On OLCF summit, storage space without purging policy is recommended /ccs/proj/[projid]. So install_path=/ccs/proj/[projid]/llvm

2. execute upstream-script.sh. About 20 minutes when the disk I/O is smooth.

3. edit the module file ../modules/llvm/main-20210112.lua by updateding
     PATH to /ccs/proj/[projid]/llvm/main-20210112/bin
     LD_LIBRARY_PATH to  /ccs/proj/[projid]/llvm/main-20210112/lib

4. update module path. obtain the path by `readlink -f ../modules`, save it as LLVM_MODULE_PATH

```
   module use $LLVM_MODULE_PATH
   module load gcc/8.1.1 llvm/main-20210112
```

   check clang to see if it is the one just built by `which clang`
   check mpi wrapper `clang --version` and `mpicc --version` agree

5. Prepare QMCPACK build script by editting qmcpack/config/build_olcf_summit_Clang.sh

change
```
# private module until OLCF provides a new llvm build
if [[ ! -d /ccs/proj/mat151/opt/modules ]] ; then
  echo "Required module folder /ccs/proj/mat151/opt/modules not found!"
  exit 1
fi
module use /ccs/proj/mat151/opt/modules
module load llvm/master-latest

```
to
```
module load llvm/main-20210112

```

6. build QMCPACK by executing `bash config/build_olcf_summit_Clang.sh` in qmcpack source directory. Once completed, `build_summit_Clang_XXX` contains QMCPACK binaries.

7. before submitting jobs, make sure llvm/main-20210112 module is available. if not, do `module use $LLVM_MODULE_PATH`

example job script

```
module load gcc/8.1.1
module load spectrum-mpi
module load cuda
module load essl
module load netlib-lapack
module load hdf5/1.10.4
module load llvm/main-20210112

NNODES=$(((LSB_DJOB_NUMPROC-1)/42))
RANKS_PER_NODE=6
RS_PER_NODE=6

exe_path=YOUR_QMCPACK_BUILD/bin

prefix=NiO-fcc-S1-dmc

export OMP_NUM_THREADS=7
jsrun -n 1 -a $RANKS_PER_NODE -c $((RANKS_PER_NODE*OMP_NUM_THREADS)) -g 6 -r 1 -d packed -b packed:$OMP_NUM_THREADS $exe_path/qmc-check-affinity > affinity.out
jsrun -n $NNODES -a $RANKS_PER_NODE -c $((RANKS_PER_NODE*OMP_NUM_THREADS)) -g 6 -r 1 -d packed -b packed:$OMP_NUM_THREADS $exe_path/qmcpack --enable-timers=fine $prefix.xml > $prefix.out
```
