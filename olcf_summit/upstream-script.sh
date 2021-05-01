prefix=/ccs/home/yeluo/opt/llvm-clang
install_path=/ccs/proj/mat151/opt/llvm

cd $prefix

if [ ! -d $prefix/llvm-project ] ; then
  git clone https://github.com/llvm/llvm-project.git
fi

cd $prefix/llvm-project

if [ $# -eq 0 ] ; then
  echo building main
  echo -----------------------------------
  build_folder=build_mirror_offload_main
  INSTALL_FOLDER=$install_path/main-`date +%Y%m%d`
  git co main
#  git pull

  #git fetch jdoerfert
  #git co feature/declare_variant_begin
  #git reset --hard jdoerfert/feature/declare_variant_begin
  PACKAGES="clang;compiler-rt"
elif [ $1 == "patched" ] ; then
  echo building patch
  echo -----------------------------------
  build_folder=build_mirror_offload_patched
  INSTALL_FOLDER=$install_path/main-patched
  #INSTALL_FOLDER=$install_path/main-20210112
  PACKAGES="clang;compiler-rt"
else
  echo building release $1
  echo -----------------------------------
  build_folder=build_mirror_offload_release
  INSTALL_FOLDER=$install_path/release-$1
  git fetch
  git co llvmorg-$1
  PACKAGES="clang;compiler-rt"
fi

#rm -rf $prefix/$build_folder
mkdir $prefix/$build_folder ; cd $prefix/$build_folder

cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
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
#    -DCMAKE_C_FLAGS=--gcc-toolchain=/ccs/home/yeluo/opt/gcc/7.4.0 \
#    -DCMAKE_CXX_FLAGS=--gcc-toolchain=/ccs/home/yeluo/opt/gcc/7.4.0 \
