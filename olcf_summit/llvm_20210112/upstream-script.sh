# prefix where to build the compiler
prefix=`pwd`
# install_path where to install the compiler
# the actual install folder is INSTALL_FOLDER below
# on OLCF summit, storage space without purging policy is recommended /ccs/proj/[projid]
install_path=$prefix

module load git cmake gcc/8.1.1 cuda
cd $prefix

if [ ! -d $prefix/llvm-project ] ; then
  git clone --shallow-since=2021-01-11 --single-branch --branch main https://github.com/llvm/llvm-project.git
fi

cd $prefix/llvm-project
git checkout bdd1ad5e5c57ae0f0bf899517c540ad8a679f01a
patch -p1 < ../openmp.cmake.patch

build_folder=build_main_offload
INSTALL_FOLDER=$install_path/main-20210112
PACKAGES="clang;compiler-rt"

#rm -rf $prefix/$build_folder
mkdir $prefix/$build_folder ; cd $prefix/$build_folder

cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DGCC_INSTALL_PREFIX=/sw/summit/gcc/8.1.1 \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_FOLDER \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_PROJECTS="$PACKAGES" \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx;openmp" \
    -DOPENMP_ENABLE_LIBOMPTARGET=ON \
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=70 \
    -DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_70 \
    -DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=ON \
    -DLIBOMPTARGET_ENABLE_DEBUG=ON \
    ../llvm-project/llvm

make -j16 && make -j16 install && chmod -w -R $INSTALL_FOLDER
